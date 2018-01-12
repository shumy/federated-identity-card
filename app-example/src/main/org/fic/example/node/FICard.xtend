package org.fic.example.node

import javafx.beans.property.StringProperty
import javafx.geometry.Insets
import javafx.scene.control.Button
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.layout.BorderPane
import javafx.scene.layout.HBox
import org.eclipse.xtend.lib.annotations.Accessors
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
  @Accessors(PUBLIC_GETTER) var CardInfo card
  
  val String tl_1
  val String tl_2
  
  new(IBroker broker, String tl_1, String tl_2) {
    super(broker)
    
    this.tl_1 = tl_1
    this.tl_2 = tl_2
    
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
    
    val rplMsg = new RplChallenge(card.block.uuid, msg.from, sigc)
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
        
        add(txtLogin)
      ]
    ]
    
    return new BorderPane => [
      top = loginBox
      bottom = txtLog
    ]
  }
  
  private def void registerAndSubscribe(String name, StringProperty logBox) {
    val cardInfo = #{ "name" -> name }
    val cardlLinks = #[
      new TrustedLink("tl-1-url", tl_1),
      new TrustedLink("tl-2-url", tl_2)
    ]
    
    logBox.value = "---Register/Subscribe START---"
    
    //create card
    card = CardHelper.create(cardInfo, cardlLinks)
    println('''CREATED-CARD: (uuid=«card.block.uuid», info=«card.block.info»)''')
    
    //register card
    channel.send(new ReqRegister(card.block.uuid, ReqRegister.NEW, card.block.retrieve))[
      if (cmd == FMessage.ACK && (it as Ack).body.code === 0)
        logBox.value = logBox.value + "\n" + '''Registered: (uuid=«card.block.uuid», name=«name»)'''
    ]
    
    //subscribe
    channel.send(new ReqSubscribe(card.block.uuid))
    logBox.value = logBox.value + "\n" + "---Register/Subscribe OK---"
  }
}