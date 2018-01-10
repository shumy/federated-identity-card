package org.fic.example.node

import javafx.scene.control.Button
import javafx.scene.layout.StackPane
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.broker.msg.request.ReqSubscribe

@FinalFieldsConstructor
class FICard extends IFicNode {
  override content() {
    new StackPane => [
      children.add(new Button => [
        text = "Subscribe"
        setOnAction[
          val msg = new ReqSubscribe(uuid, "xxx")
          channel.send(msg)[
            println("RPL: " + cmd)
          ]
        ]
      ])
    ]
  }
}