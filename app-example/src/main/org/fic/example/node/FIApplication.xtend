package org.fic.example.node

import javafx.scene.paint.Color
import javafx.scene.shape.Rectangle
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.broker.IBroker
import org.fic.broker.msg.request.ReqRegister
import org.fic.crypto.CardHelper
import org.fic.crypto.CardInfo

class FIApplication extends IFicNode {
  @Accessors(PUBLIC_GETTER) var CardInfo card
  
  new(IBroker broker) {
    super(broker)
    val cardInfo = #{ "name" -> "FIApplication" }
    
    card = CardHelper.create(cardInfo)
    println('''CREATED-CARD: (uuid=«card.block.uuid», info=«card.block.info»)''')
    
    //register card
    val msg = new ReqRegister(card.block.uuid, ReqRegister.NEW, card.block.retrieve)
    channel.send(msg)
  }
  
  override content() {
    new Rectangle(200,200, Color.RED)
  }
}