package org.fic.example.node

import javafx.scene.Node
import org.fic.broker.IBroker
import org.fic.broker.IChannel

abstract class IFicNode {
  protected val IChannel channel
  protected val IBroker broker
  
  new(IBroker broker) {
    this.broker = broker
    this.channel = broker.connect("no-url")
  }
  
  abstract def Node content()
}