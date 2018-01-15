package org.fic.example.node

import java.util.List
import javafx.beans.property.StringProperty
import javafx.geometry.Insets
import javafx.scene.control.Button
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.layout.BorderPane
import javafx.scene.layout.HBox
import org.fic.api.TrustedLink
import org.fic.broker.IBroker
import org.fic.broker.msg.Ack
import org.fic.broker.msg.FMessage
import org.fic.broker.msg.reply.RplChallenge
import org.fic.broker.msg.request.ReqChallenge
import org.fic.broker.msg.request.ReqRegister
import org.fic.broker.msg.request.ReqSubscribe
import org.fic.crypto.CardHelper
import org.fic.crypto.CardInfo
import org.fic.crypto.CipherHelper
import org.fic.crypto.SecretInfo
import org.fic.crypto.SignatureHelper

class FICard extends IFicNode {
  var String uuid
  var CardInfo card
  
  val List<TrustedLink> cardlLinks
  
  new(IBroker broker, String tl_1, String tl_2) {
    super(broker)
    
    cardlLinks = #[
      new TrustedLink("tl-1-url", tl_1),
      new TrustedLink("tl-2-url", tl_2)
    ]
    
    //process requests
    channel.onReceive[
      if (type == FMessage.REQUEST)
        switch(cmd) {
          case FMessage.CHALLENGE: challenge(it as ReqChallenge)
        }
    ]
  }
  
  private def void challenge(ReqChallenge msg) {
    //TODO: request challenge authorization?
    //TODO: no encryption mode supported?
    
    val secretInfo = new SecretInfo(msg.body.secret, msg.body.mode)
    val nonce = CipherHelper.decodeSecret(secretInfo, card.prvKey, msg.from)
    println('''  FIC-DECRYPT-CHALLENGE: (secret=«secretInfo.secret», nonce=«nonce»)''')
    
    val sigName = card.block.header.get("sign")
    val sigHelper = new SignatureHelper(sigName)
    val sigc = sigHelper.sign(card.prvKey, nonce)
    
    val rplMsg = new RplChallenge(uuid, msg.from, sigc)
    rplMsg.id = msg.id //in the same conversation
    channel.send(rplMsg)
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
          text = "Register/Subscribe"
          setOnAction[ registerAndSubscribe(txtLogin.text, txtLog.textProperty) ]
        ])
                
        add(new Button => [
          text = "Send Candidate"
          setOnAction[ sendCandidate(txtLogin.text, txtLog.textProperty) ]
        ])
        
        add(txtLogin)
      ]
    ]
    
    return new BorderPane => [
      top = loginBox
      bottom = txtLog
    ]
  }
  
  private def void registerAndSubscribe(String name, StringProperty logBox) {
    if (name == "") {
      logBox.value = "Set a value for the login name."
      return
    }
    
    logBox.value = "---Register/Subscribe START---"
    val cardInfo = #{ "name" -> name }
    
    //create card
    card = CardHelper.create(cardInfo, cardlLinks)
    uuid = card.block.uuid
    println('''CREATED-CARD: (uuid=«uuid», key=«card.block.key», info=«card.block.info»)''')
    
    //register card
    channel.send(new ReqRegister(uuid, ReqRegister.NEW, card.block.retrieve))[
      if (cmd == FMessage.ACK && (it as Ack).body.code === 0)
        logBox.value = logBox.value + "\n" + '''Registered: (uuid=«uuid», name=«name»)'''
      else {
        logBox.value = logBox.value + "\nACK: " + (it as Ack).body.error
        logBox.value = logBox.value + "\n" + "---Register/Subscribe FAIL---"
      }
    ]
    
    //subscribe
    channel.send(new ReqSubscribe(uuid))
    logBox.value = logBox.value + "\n" + "---Register/Subscribe OK---"
  }
  
  private def void sendCandidate(String name, StringProperty logBox) {
    if (name == "") {
      logBox.value = "Set a value for the login name."
      return
    }
    
    if (card === null) {
      logBox.value = "You need to Register/Subscribe first."
      return
    }
    
    logBox.value = "---Candidate START---"
    val cardInfo = #{ "name" -> name }
    
    //create card
    val candidate = CardHelper.create(uuid, cardInfo, cardlLinks)
    println('''CREATED-CARD: (uuid=«uuid», key=«candidate.block.key», info=«candidate.block.info»)''')
    
    //register card
    channel.send(new ReqRegister(uuid, ReqRegister.CANDIDATE, candidate.block.retrieve))[
      if (cmd == FMessage.ACK && (it as Ack).body.code === 0) {
        card = candidate
        logBox.value = logBox.value + "\n" + '''Candidate: (uuid=«uuid», key=«card.block.key»)'''
        logBox.value = logBox.value + "\n" + "---Candidate OK---"
      } else {
        logBox.value = logBox.value + "\nACK: " + (it as Ack).body.error
        logBox.value = logBox.value + "\n" + "---Candidate FAIL---"
      }
    ]
  }
}