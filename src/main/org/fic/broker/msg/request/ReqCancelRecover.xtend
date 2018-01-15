package org.fic.broker.msg.request

import java.util.Map
import org.fic.broker.msg.FMessage
import org.eclipse.xtend.lib.annotations.Accessors
import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include

class ReqCancelRecover extends FMessage {
  public static val CANCEL = "cnl"
  public static val RECOVER = "rec"
  
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String reqType, String uuid, String prev, String next, String secret, String key, Map<String, String> mode) {
    super(REQUEST, CR, from, to)
    this.body = new Body(reqType, uuid, prev, next, secret, key, mode)
  }
  
  @Accessors(PUBLIC_GETTER) var Body body
  
  @JsonInclude(Include.NON_NULL)
  static class Body {
    protected new() { /* used for JSON load only */ }
    new(String type, String uuid, String prev, String next, String secret, String key, Map<String, String> mode) {
      this.type = type
      this.uuid = uuid
      this.prev = prev
      this.next = next
      
      this.secret = secret
      this.key = key
      this.mode = mode
    }
    
    @Accessors(PUBLIC_GETTER) var String type
    @Accessors(PUBLIC_GETTER) var String uuid
    @Accessors(PUBLIC_GETTER) var String prev
    @Accessors(PUBLIC_GETTER) var String next
    
    @Accessors(PUBLIC_GETTER) var String secret
    @Accessors(PUBLIC_GETTER) var String key
    @Accessors(PUBLIC_GETTER) var Map<String, String> mode
  }
}