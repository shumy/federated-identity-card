package org.fic.example.node

import java.util.HashMap
import java.util.LinkedList
import java.util.UUID
import javafx.beans.property.StringProperty
import javafx.geometry.Insets
import javafx.scene.control.Button
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.layout.BorderPane
import javafx.scene.layout.HBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.api.CRLink
import org.fic.api.CardBlock
import org.fic.api.CardChain
import org.fic.api.ChainLink
import org.fic.broker.IBroker
import org.fic.broker.msg.Ack
import org.fic.broker.msg.FMessage
import org.fic.broker.msg.reply.RplEvolve
import org.fic.broker.msg.reply.RplSearch
import org.fic.broker.msg.reply.RplChallenge
import org.fic.broker.msg.request.ReqChallenge
import org.fic.broker.msg.request.ReqEvolve
import org.fic.broker.msg.request.ReqRegister
import org.fic.broker.msg.request.ReqSearch
import org.fic.broker.msg.request.ReqSubscribe
import org.fic.crypto.CardHelper
import org.fic.crypto.CardInfo
import org.fic.crypto.CipherHelper
import org.fic.crypto.KeyLoaderHelper
import org.fic.crypto.SignatureHelper
import org.fic.crypto.SecretInfo

import static extension org.fic.crypto.Base64Helper.*

class FIApplication extends IFicNode {
  @Accessors(PUBLIC_GETTER) var CardInfo card
  
  val logins = new HashMap<String, String>                      // name - uuid
  val chains = new HashMap<String, CardChain>                   // uuid - CardChain
  
  new(IBroker broker) {
    super(broker)
    val cardInfo = #{ "name" -> "FIApplication" }
    
    //process requests
    channel.onReceive[
      if (type == FMessage.REQUEST)
        switch(cmd) {
          case FMessage.CHALLENGE: challenge(it as ReqChallenge)
        }
    ]
    
    card = CardHelper.create(cardInfo)
    println('''CREATED-CARD: (uuid=«card.block.uuid», info=«card.block.info»)''')
    
    //register card
    channel.send(new ReqRegister(card.block.uuid, ReqRegister.NEW, card.block.retrieve))
    
    //subscribe
    channel.send(new ReqSubscribe(card.block.uuid))
  }
  
  override content() {
    val txtLogin = new TextField => [
      prefWidth = 400
      promptText = "Enter login name here..."
    ]
    
    val txtLog = new TextArea => [
      editable = false
      wrapText = true
      prefRowCount = 10
    ]
    
    val loginBox = new HBox => [
      padding = new Insets(15, 12, 15, 12)
      spacing = 10
      style = "-fx-background-color: #336699;"
      
      children => [
        add(new Button => [
          text = "Login"
          setOnAction[ tryLogin(txtLogin.text, txtLog.textProperty) ]
        ])
        
        add(txtLogin)
      ]
    ] 
    
    return new BorderPane => [
      top = loginBox
      bottom = txtLog
    ]
  }
  
  private def void challenge(ReqChallenge msg) {
    //TODO: request challenge authorization?
    //TODO: no encryption mode supported?
    
    val secretInfo = new SecretInfo(msg.body.secret, msg.body.mode)
    val nonce = CipherHelper.decodeSecret(secretInfo, card.prvKey, msg.from)
    println('''  FIA-DECRYPT-CHALLENGE: (secret=«secretInfo.secret», nonce=«nonce»)''')
    
    val sigName = card.block.header.get("sign")
    val sigHelper = new SignatureHelper(sigName)
    val sigc = sigHelper.sign(card.prvKey, nonce)
    
    val rplMsg = new RplChallenge(card.block.uuid, msg.from, sigc)
    rplMsg.id = msg.id //in the same conversation
    channel.send(rplMsg)
  }
  
  private def void search(String name, StringProperty logBox) {
    if (logins.get(name) === null) {
      logBox.value = logBox.value + "\n" + "Card not found in local database..."
      logBox.value = logBox.value + "\n" + "Searching in gateway..."
      val msg = new ReqSearch(card.block.uuid, name)
      channel.send(msg)[
        if (cmd == FMessage.ACK) {
          val ack = it as Ack
          logBox.value = logBox.value + "\n" + "Search error: " + ack.body.error
        }
        
        if (cmd == FMessage.SEARCH) {
          val rpl = it as RplSearch
          if (rpl.body.result.length == 0) {
            logBox.value = logBox.value + "\n" + "No search results!"
            return
          } else {
            val line = rpl.body.result.get(0)
            val rUuid = line.get("uuid")
            val rStart = line.get("active")
            
            logBox.value = logBox.value + "\n" + '''Evolve: (uuid=«rUuid», active=«rStart»)'''
            
            //load card from the gateway...
            tryEvolve(rUuid, rStart)
            logins.put(name, rUuid)
          }
        }
      ]
    }
  }
  
  private def void tryLogin(String name, StringProperty logBox) {
    if (name == "") {
      logBox.value = "Set a value for the login name."
      return
    }
    
    logBox.value = "---Login START---"
    logBox.value = logBox.value + "\n" + "Try login with: " + name
    
    // search login card...
    search(name, logBox)
    
    val uuid = logins.get(name)
    if (uuid !== null) {
      val chain = chains.get(uuid)
      
      //create secret...
      val nonce = UUID.randomUUID.toString
      val secretInfo = CipherHelper.createSecret(nonce, card.prvKey, chain.card.pubKey)
      
      //request challenge...
      logBox.value = logBox.value + "\n" + '''Challenging: (uuid=«uuid», nonce=«nonce»)'''
      val chMsg = new ReqChallenge(card.block.uuid, uuid, secretInfo.secret, secretInfo.mode)
      channel.send(chMsg)[
        if (cmd == FMessage.CHALLENGE) {
          val rplCh = it as RplChallenge
          val sigName = chain.card.header.get("sign")
          val sigHelper = new SignatureHelper(sigName)
          
          val isValid = sigHelper.verifySignature(chain.card.pubKey, nonce, rplCh.body.sigc)
          if (isValid)
            logBox.value = logBox.value + "\n" + "---Login OK---"
        } else {
          if (cmd == FMessage.ACK)
            logBox.value = logBox.value + "\nACK: " + (it as Ack).body.error
             
          logBox.value = logBox.value + "\n" + "---Login FAILED---"
        }
      ]
    }
  }
  
  private def void tryEvolve(String uuid, String start) {
    val elvMsg = new ReqEvolve(card.block.uuid, uuid, start)
    channel.send(elvMsg)[
      if (cmd == FMessage.EVOLVE) {
        val rplMsg = it as RplEvolve
        
        val nonce = rplMsg.body.chain
          .fold("")[ r, next | r + "-" + next.toString ]
        
        val klHelper = new KeyLoaderHelper(rplMsg.body.mode.get("curve"))
        val pubKey = klHelper.loadPublicKey(rplMsg.from.decode)
        
        val sigName = rplMsg.body.mode.get("suite")
        val sigHelper = new SignatureHelper(sigName)
        
        //validated the evolve chain with the gateway signature
        val isOk = sigHelper.verifySignature(pubKey, nonce, rplMsg.body.sign)
        if (!isOk) return;
        
        println("-----Try-evolve signature OK-----")
        val chainLinks = new LinkedList<ChainLink>
        rplMsg.body.chain.forEach[ cs | //for some weird reason the map function is executing more than size times!!!!
          val card = CardBlock.load(cs.card)
          val links = cs.links.map[ CRLink.load(it) ]
          chainLinks.add(new ChainLink(card, links))
        ]
        
        //update or create card-chain
        val chain = chains.get(uuid)
        if (chain === null)
          chains.put(uuid, new CardChain(chainLinks))
        else
          chain.merge(chainLinks)
      }
    ]
  }
}