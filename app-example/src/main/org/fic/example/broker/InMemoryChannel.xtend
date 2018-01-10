package org.fic.example.broker

import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.broker.IChannel
import org.fic.broker.msg.FMessage
import org.fic.broker.msg.reply.RplAck

@FinalFieldsConstructor
class InMemoryChannel implements IChannel {
  val String uuid
  val InMemoryBroker broker
  
  val executor = Executors.newSingleThreadScheduledExecutor
  val replyListeners = new ConcurrentHashMap<Long, (FMessage)=>void>
  
  var (FMessage)=>void onMessage = null
  
  package def void receive(FMessage msg) {
    if (msg.type == FMessage.REQUEST && onMessage !== null) {
      onMessage.apply(msg)  
    } else if (msg.type == FMessage.REPLY) {
      val rpl = replyListeners.remove(msg.id)
      rpl?.apply(msg)
    }
  }
  
  override send(FMessage msg) {
    broker.publish(msg)
  }
  
  override send(FMessage msg, (FMessage)=>void onReply) {
    msg.id = broker.next.andIncrement
    replyListeners.put(msg.id, onReply)
    
    //timeout handler...
    executor.schedule([
      val rpl = replyListeners.remove(msg.id)
      rpl?.apply(new RplAck(msg.to, msg.from, RplAck.TIMEOUT))
      
      return null
    ], 5, TimeUnit.SECONDS)
    
    broker.publish(msg)
  }
  
  override onReceive((FMessage)=>void onMessage) {
    this.onMessage = onMessage
  }
  
  override disconnect() {
    executor.shutdown()
    broker.remove(uuid)
  }
  
  override onDisconnect((Throwable)=>void onDisconnect) {
    throw new UnsupportedOperationException("onDisconnect is not used in InMemoryChannel")
  }
}