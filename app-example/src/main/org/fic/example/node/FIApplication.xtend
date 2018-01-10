package org.fic.example.node

import javafx.scene.paint.Color
import javafx.scene.shape.Rectangle
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class FIApplication extends IFicNode {
  override content() {
    new Rectangle(200,200, Color.RED)
  }
}