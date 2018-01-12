package org.fic.example.broker

import com.fasterxml.jackson.databind.ObjectMapper
import java.util.HashSet
import java.util.concurrent.atomic.AtomicLong
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.broker.IBroker
import org.fic.broker.msg.FMessage

@FinalFieldsConstructor
class InMemoryBroker implements IBroker {
  package val next = new AtomicLong(1)
  val InMemoryGateway gateway
  
  val mapper = new ObjectMapper
  val channels = new HashSet<InMemoryChannel>
  
  var (String)=>void onMessage = null
  
  def logTo((String)=>void onMessage) {
    this.onMessage = onMessage
  }
  
  override connect(String url) {
    // Simulates gateway connection...
    val ch = new InMemoryChannel(this)
    gateway.connect(ch.chUUID)[
      // Simulates receiving from the gateway...
      received(ch, it)
    ]
    
    return ch
  }
  
  package def void disconnect(InMemoryChannel channel) {
    // Simulates gateway disconnection...
    channels.remove(channel)
    gateway.disconnect(channel.chUUID)
  }
  
  package def void publish(InMemoryChannel ch, FMessage msg) {
    // Simulates publishing to the gateway...
    val json = mapper.writeValueAsString(msg)
    onMessage?.apply(json)
    
    //if this was a real network transmission, the message would be sent here.
    println('''PUBLISH: «json»''')
    gateway.publish(ch.chUUID, json)
  }
  
  private def void received(InMemoryChannel channel, String json) {
    //if this was a real network transmission, the message would be received here.
    println('''RECEIVED: «json»''')
    
    val tree = mapper.readTree(json)
    val mType = tree.get("type")?.asText
    val mCmd = tree.get("cmd").asText
    val mClass = FMessage.select(mType, mCmd)
    
    println('''  DECODED: («mType», «mCmd», «mClass.simpleName»)''')
    val fMsg = mapper.treeToValue(tree, mClass) as FMessage
    
    channel.received(fMsg)
  }
}