package org.fic.example.broker

import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.broker.IChannel
import org.fic.broker.msg.Ack
import org.fic.broker.msg.FMessage

@FinalFieldsConstructor
class InMemoryChannel implements IChannel {
  public val String chUUID = UUID.randomUUID.toString
  
  val InMemoryBroker broker
  val executor = Executors.newSingleThreadScheduledExecutor
  val replyListeners = new ConcurrentHashMap<Long, (FMessage)=>void>
  
  var (FMessage)=>void onMessage = null
  
  package def void received(FMessage msg) {
    if (msg.type == FMessage.REQUEST && onMessage !== null) {
      onMessage.apply(msg)
    } else if (msg.type == FMessage.REPLY || msg.cmd == FMessage.ACK) {
      val rpl = replyListeners.remove(msg.id)
      rpl?.apply(msg)
    }
  }
  
  override send(FMessage msg) {
    send(msg, null)
  }
  
  override send(FMessage msg, (FMessage)=>void onReply) {
    if (msg.id === null)
      msg.id = broker.next.andIncrement
    
    if (onReply !== null) {
      replyListeners.put(msg.id, onReply)
      
      //timeout handler...
      executor.schedule([
        val rpl = replyListeners.remove(msg.id)
        rpl?.apply(new Ack(msg.to, msg.from, Ack.TIMEOUT))
        
        return null
      ], 5, TimeUnit.SECONDS)
    }
    
    broker.publish(this, msg)
  }
  
  override onReceive((FMessage)=>void onMessage) {
    this.onMessage = onMessage
  }
  
  override disconnect() {
    executor.shutdown()
    broker.disconnect(this)
  }
  
  override onDisconnect((Throwable)=>void onDisconnect) {
    throw new UnsupportedOperationException("onDisconnect is not used in InMemoryChannel")
  }
}