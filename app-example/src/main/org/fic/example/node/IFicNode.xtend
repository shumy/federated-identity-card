package org.fic.example.node

import java.util.UUID
import javafx.scene.Node
import org.fic.broker.IBroker
import org.fic.broker.IChannel

abstract class IFicNode {
  protected val String uuid
  protected val IChannel channel
  
  val IBroker broker
  
  new(IBroker broker) {
    this.broker = broker
    this.uuid = UUID.randomUUID.toString
    this.channel = broker.connect("no-url", uuid)
  }
  
  abstract def Node content()
}