package org.fic.example.broker

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import java.util.HashMap
import java.util.UUID
import org.fic.api.CardBlock
import org.fic.api.CardChain
import org.fic.broker.msg.FMessage
import org.fic.broker.msg.reply.RplAck
import org.fic.broker.msg.reply.RplChallenge
import org.fic.broker.msg.request.ReqChallenge
import org.fic.broker.msg.request.ReqRegister
import org.fic.broker.msg.request.ReqSubscribe
import org.fic.crypto.CardHelper
import org.fic.crypto.CardInfo
import org.fic.crypto.CipherHelper
import org.fic.crypto.SignatureHelper
import java.util.concurrent.ConcurrentHashMap

class InMemoryGateway {
  val mapper = new ObjectMapper
  
  val channels = new HashMap<String, (String)=>void>            // chUUID -> handler
  
  //routes...
  val invRoutes = new HashMap<String, String>                   // chUUID -> public-key
  val routes = new HashMap<String, String>                      // public-key -> chUUID
  
  //cards and chains
  val CardInfo card
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
      route(json, to.asText)
  }
  
  private def void reply(String chUUID, Long id, FMessage fMsg) {
    fMsg.id = id
    println('''  GT-REPLY: (chUUID=«chUUID», id=«id», to=«fMsg.to»)''')
    
    val json = mapper.writeValueAsString(fMsg)
    
    val ch = channels.get(chUUID)
    ch?.apply(json)
  }
  
  private def void route(String json, String to) {
    println('''  GT-ROUTE-TO: «to»''')
    
    val chUUID = routes.get(to)
    if (chUUID !== null) {
      // Simulates sending message from component...
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
      }
    
    if (mType == FMessage.REPLY)
      switch(mCmd) {
        case FMessage.CHALLENGE: challengeReply(chUUID, fMsg as RplChallenge)
      }
  }
  
  private def void register(String chUUID, ReqRegister msg) {
    val loadedCard = CardBlock.load(msg.body.card)
    println('''  GT-REGISTER: (type=«msg.body.type», card=«loadedCard.uuid»)''')
    
    val chain = chains.get(loadedCard.uuid)
    if (msg.body.type == ReqRegister.NEW) {
      if (chain !== null) {
        // card-chain already exists!
        reply(chUUID, msg.id, new RplAck(card.block.key, msg.from, RplAck.REG_EXISTENT_CARD))
        return
      }
      
      chains.put(loadedCard.uuid, new CardChain(loadedCard))
    } else {
      if (chain === null) {
        // non existent card-chain
        reply(chUUID, msg.id, new RplAck(card.block.key, msg.from, RplAck.NO_CHAIN))
        return
      }
      
      if (chain.active) {
        // candidate not accepted, card-chain is still active!
        reply(chUUID, msg.id, new RplAck(card.block.key, msg.from, RplAck.CHAIN_ACTIVE))
        return
      }
      
      chain.addCandidate(loadedCard)
    }
    
    // card-block registered with success
    reply(chUUID, msg.id, new RplAck(card.block.key, msg.from, RplAck.OK))
  }
  
  private def void subscribe(String chUUID, ReqSubscribe msg) {
    println('''  GT-SUBSCRIBE: «chUUID» => «msg.from»''')
    
    val chain = chains.get(msg.from)
    if (chain === null) {
      // non existent card-chain
      reply(chUUID, msg.id, new RplAck(card.block.key, msg.from, RplAck.NO_CHAIN))
      return
    }
    
    if (!chain.active) {
      // subscription not accepted, card-chain is not active! Needs to recover.
      reply(chUUID, msg.id, new RplAck(card.block.key, msg.from, RplAck.CHAIN_INACTIVE))
      return
    }
    
    //create secret...
    val nonce = UUID.randomUUID.toString
    val secretInfo = CipherHelper.createSecret(nonce, card.prvKey, chain.card.pubKey)
    
    //TODO: remove on timeout
    pendingChallenges.put(msg.from, nonce)
    
    //request challenge...
    println('''  GT-ENCRYPT-CHALLENGE: (nonce=«nonce», secret=«secretInfo.secret»)''')
    reply(chUUID, msg.id, new ReqChallenge(card.block.key, msg.from, secretInfo.secret, secretInfo.mode))
  }
  
  private def void challengeReply(String chUUID, RplChallenge msg) {
    val chain = chains.get(msg.from)
    if (chain === null) {
      reply(chUUID, msg.id, new RplAck(card.block.key, msg.from, RplAck.NO_CHAIN))
      return
    }
    
    val nonce = pendingChallenges.remove(msg.from)
    val sigName = chain.card.header.get("sign")
    val sigHelper = new SignatureHelper(sigName)
    
    val isValid = sigHelper.verifySignature(chain.card.pubKey, nonce, msg.body.sigc)
    if (!isValid) {
      reply(chUUID, msg.id, new RplAck(card.block.key, msg.from, RplAck.SIGNATURE))
      return
    }
    
    //TODO: if route already exists !?
    println('''  GT-CHALLENGE-ACCEPTED: (nonce=«nonce»''')
    routes.put(msg.from, chUUID)
    invRoutes.put(chUUID, msg.from)
  }
}