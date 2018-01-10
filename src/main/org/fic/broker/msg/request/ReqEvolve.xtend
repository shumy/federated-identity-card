package org.fic.broker.msg.request

import org.fic.broker.msg.FMessage

class ReqEvolve extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String uuid, String start) {
    super(REQUEST, EVOLVE, from, to)
    
    body.put("uuid", uuid)
    body.put("start", start)
  }
  
  def getUuid() { body.get("uuid") as String }
  def getStart() { body.get("start") as String }
}