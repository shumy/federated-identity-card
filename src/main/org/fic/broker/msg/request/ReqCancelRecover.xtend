package org.fic.broker.msg.request

import org.fic.broker.msg.FMessage
import org.fic.broker.msg.SecretStruct

class ReqCancelRecover extends FMessage {
  public static val CANCEL = "cnl"
  public static val RECOVER = "rec"
  
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String reqType, String uuid, String prev, String next, SecretStruct secret) {
    super(REQUEST, CR, from, to)
    
    body.put("type", reqType)
    body.put("uuid", uuid)
    body.put("prev", prev)
    body.put("next", next)
    
    body.put("secret", secret)
  }
  
  def getRequestType() { body.get("type") as String }
  def getUuid() { body.get("uuid") as String }
  def getPrev() { body.get("prev") as String }
  def getNext() { body.get("next") as String }
  
  def getSecret() { body.get("secret") as SecretStruct }
}