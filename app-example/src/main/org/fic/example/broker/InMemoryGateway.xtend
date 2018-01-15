package org.fic.example.broker

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import java.util.HashMap
import java.util.Map
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import org.fic.api.CRLink
import org.fic.api.CardBlock
import org.fic.api.CardChain
import org.fic.broker.msg.Ack
import org.fic.broker.msg.FMessage
import org.fic.broker.msg.reply.ChainStruct
import org.fic.broker.msg.reply.RplChallenge
import org.fic.broker.msg.reply.RplEvolve
import org.fic.broker.msg.reply.RplSearch
import org.fic.broker.msg.request.ReqCRLink
import org.fic.broker.msg.request.ReqChallenge
import org.fic.broker.msg.request.ReqEvolve
import org.fic.broker.msg.request.ReqRegister
import org.fic.broker.msg.request.ReqSearch
import org.fic.broker.msg.request.ReqSubscribe
import org.fic.crypto.CardHelper
import org.fic.crypto.CardInfo
import org.fic.crypto.CipherHelper
import org.fic.crypto.SignatureHelper

class InMemoryGateway {
  val mapper = new ObjectMapper
  
  val channels = new HashMap<String, (String)=>void>            // chUUID -> handler
  
  //routes...
  val invRoutes = new HashMap<String, String>                   // chUUID -> public-key
  val routes = new HashMap<String, String>                      // public-key -> chUUID
  
  //cards / chains / logins
  val CardInfo card
  val logins = new HashMap<String, String>                      // name - uuid
  val chains = new HashMap<String, CardChain>                   // uuid - CardChain
  
  val pendingChallenges = new ConcurrentHashMap<String, String> // from - nonce
  
  new() {
    val cardInfo = #{ "name" -> "FIGateway" }
    
    card = CardHelper.create(cardInfo)
    println('''CREATED-CARD: (uuid=«card.block.uuid», info=«card.block.info»)''')
  }
  
  def void connect(String chUUID, (String)=>void onReceive) {
    channels.put(chUUID, onReceive)
  }
  
  def void disconnect(String chUUID) {
    channels.remove(chUUID)
    
    // remove from routes if exits
    val uuid = invRoutes.remove(chUUID)
    routes?.remove(uuid)
  }
  
  def void publish(String chUUID, String json) {
    // Simulates receiving message from component...
    val tree = mapper.readTree(json)
    val to = tree.get("to")
    
    if (to === null || to.asText == card.block.key)
      process(chUUID, tree)
    else
      route(chUUID, tree, json, to.asText)
  }
  
  private def void reply(String chUUID, Long id, FMessage fMsg) {
    fMsg.id = id
    println('''  GT-REPLY: (chUUID=«chUUID», id=«id», to=«fMsg.to»)''')
    
    val json = mapper.writeValueAsString(fMsg)
    
    val ch = channels.get(chUUID)
    ch?.apply(json)
  }
  
  private def void route(String rplChUUID, JsonNode tree, String json, String to) {
    // Simulates sending message from component...
    println('''  GT-ROUTE-TO: «to»''')
    
    val chUUID = routes.get(to)
    if (chUUID !== null) {
      val id = tree.get("id").asLong
      val type = tree.get("type").asText
      val cmd = tree.get("cmd").asText
      val from = tree.get("from").asText
      
      // if the chain is inactive, reply with CHAIN_INACTIVE
      val chain = chains.get(to)
      if (!chain.active) {
        println('''    Route inactive: «to»''')
        reply(rplChUUID, id, new Ack(card.block.key, from, Ack.CHAIN_INACTIVE))
        return
      }
      
      if (type == FMessage.REQUEST && cmd == FMessage.CHALLENGE) {
        val fMsg = mapper.treeToValue(tree, ReqChallenge)
        
        println('''  GT-ROUTE-VERIFY: (to=«to», chain.key=«chain.card.key», msg.key=«fMsg.body.key»)''')
        if (chain.card.key != fMsg.body.key) {
          println('''    Challenge wrong key!''')
          reply(rplChUUID, id, new Ack(card.block.key, from, Ack.CHA_NO_SYNC))
          return
        }
      }
      
      val ch = channels.get(chUUID)
      ch.apply(json)
    } else
      println('''    No route to: «to»''')
  }
  
  private def void process(String chUUID, JsonNode tree) {
    val mType = tree.get("type").asText
    val mCmd = tree.get("cmd").asText
    val mClass = FMessage.select(mType, mCmd)
    
    println('''  GT-PROCESS: (type=«mType», cmd=«mCmd») => «mClass.simpleName»''')
    val fMsg = mapper.treeToValue(tree, mClass) as FMessage
    
    if (mType == FMessage.REQUEST)
      switch(mCmd) {
        case FMessage.REGISTER: register(chUUID, fMsg as ReqRegister)
        case FMessage.SUBSCRIBE: subscribe(chUUID, fMsg as ReqSubscribe)
        case FMessage.SEARCH: search(chUUID, fMsg as ReqSearch)
        case FMessage.EVOLVE: evolve(chUUID, fMsg as ReqEvolve)
        case FMessage.CR_LINK: crLink(chUUID, fMsg as ReqCRLink)
      }
    
    if (mType == FMessage.REPLY)
      switch(mCmd) {
        case FMessage.CHALLENGE: challengeReply(chUUID, fMsg as RplChallenge)
      }
  }
  
  private def void register(String chUUID, ReqRegister msg) {
    val loadedCard = CardBlock.load(msg.body.card)
    println('''  GT-REGISTER: (type=«msg.body.type», card=«loadedCard.key», info=«loadedCard.info»)''')
    
    val chain = chains.get(loadedCard.uuid)
    if (msg.body.type == ReqRegister.NEW) {
      if (chain !== null) {
        // card-chain already exists!
        reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.REG_EXISTENT_CARD))
        return
      }
      
      logins.put(loadedCard.info.get("name"), loadedCard.uuid)
      chains.put(loadedCard.uuid, new CardChain(loadedCard))
    } else {
      if (chain === null) {
        // non existent card-chain
        reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.NO_CHAIN))
        return
      }
      
      if (chain.active) {
        // candidate not accepted, card-chain is still active!
        reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.CHAIN_ACTIVE))
        return
      }
      
      chain.addCandidate(loadedCard)
    }
    
    // card-block registered with success
    reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.OK))
  }
  
  private def void subscribe(String chUUID, ReqSubscribe msg) {
    println('''  GT-SUBSCRIBE: «chUUID» => «msg.from»''')
    
    val chain = chains.get(msg.from)
    if (chain === null) {
      // non existent card-chain
      reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.NO_CHAIN))
      return
    }
    
    if (!chain.active) {
      // subscription not accepted, card-chain is not active! Needs to recover.
      reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.CHAIN_INACTIVE))
      return
    }
    
    //create secret...
    val nonce = UUID.randomUUID.toString
    val secretInfo = CipherHelper.createSecret(nonce, card.prvKey, chain.card.pubKey)
    
    //TODO: remove on timeout
    pendingChallenges.put(msg.from, nonce)
    
    //request challenge...
    println('''  GT-ENCRYPT-CHALLENGE: (nonce=«nonce», secret=«secretInfo.secret»)''')
    reply(chUUID, msg.id, new ReqChallenge(card.block.key, msg.from, secretInfo.secret, chain.card.key, secretInfo.mode))
  }
  
  private def void search(String chUUID, ReqSearch msg) {
    //this is not a full query implementation...
    println('''  GT-SEARCH: (query=«msg.body.query»)''')
    val uuid = logins.get(msg.body.query)
    val result = if(uuid === null) #[] else {
      val chain = chains.get(uuid)
      val line = new HashMap<String, String> => [
        put("uuid", chain.uuid)
        put("active", "" + chain.active)
        put("last", chain.card.key)
        putAll(chain.card.info)
      ]
      
      #[ line as Map<String, String> ]
    }
    
    reply(chUUID, msg.id, new RplSearch(card.block.key, msg.from, result))
  }
  
  private def void evolve(String chUUID, ReqEvolve msg) {
    println('''  GT-EVOLVE: (uuid=«msg.body.uuid», start=«msg.body.start»)''')
    val chain = chains.get(msg.body.uuid)
    if (chain === null) {
      reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.NO_CHAIN))
      return
    }
    
    //simplified version returns all cards from the chain, not just from start...
    val chainStruct = chain.chain.map[ cl |
      val sLinks = cl.links.map[ retrieve ]
      new ChainStruct(cl.card.retrieve, sLinks)
    ]
    
    val nonce = chainStruct
      .fold("")[ r, next | r + "-" + next.toString ]
    
    val sigName = card.block.header.get("sign")
    val sigHelper = new SignatureHelper(sigName)
    val sign = sigHelper.sign(card.prvKey, nonce)
    
    reply(chUUID, msg.id, new RplEvolve(card.block.key, msg.from, chainStruct, sign, #{ "suite" -> sigName, "curve" -> "secp384r1" }))
  }
  
  private def void crLink(String chUUID, ReqCRLink msg) {
    val crLink = CRLink.load(msg.body.lnk)
    val chain = chains.get(crLink.uuid)
    if (chain === null) {
      reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.NO_CHAIN))
      return
    }
    
    if (crLink.type === CRLink.CANCEL)
      println('''  GT-CANCEL-LNK: (uuid=«crLink.uuid», prev=«crLink.prev»)''')
    else
      println('''  GT-RECOVER-LNK: (uuid=«crLink.uuid», prev=«crLink.prev», next=«crLink.next»)''')
    
    chain.addLink(crLink)
    println('''  GT-CHAIN-STATUS: (uuid=«chain.uuid», current=«chain.card.key», active=«chain.active»)''')
    
    reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.OK))
  }
  
  private def void challengeReply(String chUUID, RplChallenge msg) {
    val chain = chains.get(msg.from)
    if (chain === null) {
      reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.NO_CHAIN))
      return
    }
    
    val nonce = pendingChallenges.remove(msg.from)
    val sigName = chain.card.header.get("sign")
    val sigHelper = new SignatureHelper(sigName)
    
    val isValid = sigHelper.verifySignature(chain.card.pubKey, nonce, msg.body.sigc)
    if (!isValid) {
      reply(chUUID, msg.id, new Ack(card.block.key, msg.from, Ack.SIGNATURE))
      return
    }
    
    //TODO: if route already exists !?
    println('''  GT-CHALLENGE-ACCEPTED: (nonce=«nonce»)''')
    routes.put(msg.from, chUUID)
    invRoutes.put(chUUID, msg.from)
  }
}