package org.fic.example.node

import javafx.scene.control.Button
import javafx.scene.layout.StackPane
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.api.TrustedLink
import org.fic.broker.IBroker
import org.fic.broker.msg.FMessage
import org.fic.broker.msg.request.ReqChallenge
import org.fic.broker.msg.request.ReqRegister
import org.fic.broker.msg.request.ReqSubscribe
import org.fic.broker.msg.reply.RplChallenge
import org.fic.crypto.CardHelper
import org.fic.crypto.CardInfo
import org.fic.crypto.CipherHelper
import org.fic.crypto.SecretInfo
import org.fic.crypto.SignatureHelper


class FICard extends IFicNode {
  @Accessors(PUBLIC_GETTER) var CardInfo card
  
  new(IBroker broker, String tl_1, String tl_2) {
    super(broker)
    
    val cardInfo = #{ "name" -> "FICard" }
    val cardlLinks = #[
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
    
    //create card
    card = CardHelper.create(cardInfo, cardlLinks)
    println('''CREATED-CARD: (uuid=«card.block.uuid», info=«card.block.info»)''')
    
    //register card
    channel.send(new ReqRegister(card.block.uuid, ReqRegister.NEW, card.block.retrieve))
    
    //subscribe
    channel.send(new ReqSubscribe(card.block.uuid))
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
    new StackPane => [
      children.add(new Button => [
        text = "Subscribe"
        setOnAction[
          val msg = new ReqSubscribe(card.block.uuid)
          channel.send(msg)
        ]
      ])
    ]
  }
}