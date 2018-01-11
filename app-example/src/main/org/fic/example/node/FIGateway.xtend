package org.fic.example.node

import javafx.scene.paint.Color
import javafx.scene.shape.Rectangle
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.crypto.CardInfo
import org.fic.example.broker.InMemoryGateway

@FinalFieldsConstructor
class FIGateway extends IFicNode {
  @Accessors(PUBLIC_GETTER) var CardInfo card
  
  //val InMemoryGateway gt
  
  override content() {
    new Rectangle(200,200, Color.RED)
  }
}