package org.fic.broker.msg.request

import java.util.Map
import org.fic.broker.msg.FMessage

class ReqCancelRecover extends FMessage {
  public static val CANCEL = "cnl"
  public static val RECOVER = "rec"
  
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String reqType, String uuid, String prev, String next, String secret, Map<String, String> mode) {
    super(REQUEST, CR, from, to)
    
    body.put("type", reqType)
    body.put("uuid", uuid)
    body.put("prev", prev)
    body.put("next", next)
    
    body.put("secret", secret)
  }
}