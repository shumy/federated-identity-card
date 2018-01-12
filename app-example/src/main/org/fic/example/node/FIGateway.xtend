package org.fic.example.node

import javafx.scene.control.TextArea
import javafx.scene.layout.BorderPane
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.crypto.CardInfo

@FinalFieldsConstructor
class FIGateway extends IFicNode {
  @Accessors(PUBLIC_GETTER) var CardInfo card
  
  override content() {
    val txtLog = new TextArea => [
      editable = false
      wrapText = true
      prefRowCount = 10
    ]
    
    return new BorderPane => [
      bottom = txtLog
    ]
  }
}