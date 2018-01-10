package org.fic.example.broker

import com.fasterxml.jackson.databind.ObjectMapper
import java.util.HashMap
import java.util.concurrent.atomic.AtomicLong
import org.fic.broker.IBroker
import org.fic.broker.msg.FMessage
import org.fic.broker.msg.reply.RplAck
import org.fic.broker.msg.reply.RplChallenge
import org.fic.broker.msg.reply.RplEvolve
import org.fic.broker.msg.reply.RplSearch
import org.fic.broker.msg.request.ReqCRLink
import org.fic.broker.msg.request.ReqCancelRecover
import org.fic.broker.msg.request.ReqChallenge
import org.fic.broker.msg.request.ReqEvolve
import org.fic.broker.msg.request.ReqRegister
import org.fic.broker.msg.request.ReqSearch
import org.fic.broker.msg.request.ReqSubscribe

class InMemoryBroker implements IBroker {
  package val next = new AtomicLong(1)
  
  val mapper = new ObjectMapper
  val channels = new HashMap<String, InMemoryChannel>
  var (String)=>void onMessage = null
  
  def logTo((String)=>void onMessage) {
    this.onMessage = onMessage
  }
  
  override connect(String url, String uuid) {
    val ch = new InMemoryChannel(uuid, this)
    channels.put(uuid, ch)
    return ch
  }
  
  package def remove(String uuid) {
    channels.remove(uuid)
  }
  
  package def void publish(FMessage msg) {
    //serialize => log => deserialize => route
    
    val json = mapper.writeValueAsString(msg)
    onMessage?.apply(json)
    println('''PUBLISH: «json»''')
    
    val tree = mapper.readTree(json)
    val mType = tree.get("type").asText
    val mCmd = tree.get("cmd").asText
    val clazz = selectClass(mType, mCmd)
    
    val fMsg = mapper.treeToValue(tree, clazz) as FMessage
    
    println('''ROUTED: «fMsg.class.simpleName» => («fMsg.id», «fMsg.from», «fMsg.to», «fMsg.type»-«fMsg.cmd»)''')
    val route = channels.get(msg.to)
    route?.receive(fMsg)
  }
  
  private def Class<?> selectClass(String type, String cmd) {
    if (type == FMessage.REQUEST) {
      switch (cmd) {
        case FMessage.CHALLENGE: return ReqChallenge
        case FMessage.SUBSCRIBE: return ReqSubscribe
        case FMessage.REGISTER: return ReqRegister
        case FMessage.CR: return ReqCancelRecover
        case FMessage.CR_LINK: return ReqCRLink
        case FMessage.SEARCH: return ReqSearch
        case FMessage.EVOLVE: return ReqEvolve
      }
    } else if (type == FMessage.REPLY) {
      switch (cmd) {
        case FMessage.ACK: return RplAck
        case FMessage.CHALLENGE: return RplChallenge
        case FMessage.SEARCH: return RplSearch
        case FMessage.EVOLVE: return RplEvolve
      }
    }
  }
}