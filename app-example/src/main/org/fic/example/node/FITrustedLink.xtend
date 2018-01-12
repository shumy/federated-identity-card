package org.fic.example.node

import javafx.scene.paint.Color
import javafx.scene.shape.Rectangle
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.broker.IBroker
import org.fic.broker.msg.request.ReqRegister
import org.fic.broker.msg.request.ReqSubscribe
import org.fic.crypto.CardHelper
import org.fic.crypto.CardInfo

class FITrustedLink extends IFicNode {
  static var counter = 1
  
  @Accessors(PUBLIC_GETTER) var CardInfo card
  
  new(IBroker broker) {
    super(broker)
    val cardInfo = #{ "name" -> "FITrustedLink-" + counter++ }
    
    card = CardHelper.create(cardInfo)
    println('''CREATED-CARD: (uuid=«card.block.uuid», info=«card.block.info»)''')
    
    //register card
    channel.send(new ReqRegister(card.block.uuid, ReqRegister.NEW, card.block.retrieve))
    
    //subscribe
    channel.send(new ReqSubscribe(card.block.uuid))
  }
  
  override content() {
    new Rectangle(200,200, Color.RED)
  }
}