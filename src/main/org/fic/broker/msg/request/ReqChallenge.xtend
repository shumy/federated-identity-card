package org.fic.broker.msg.request

import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.broker.msg.FMessage

class ReqChallenge extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String secret, Map<String, String> mode) {
    super(REQUEST, CHALLENGE, from, to)
    this.body = new Body(secret, mode) 
  }
  
  @Accessors(PUBLIC_GETTER) var Body body
  
  @JsonInclude(Include.NON_NULL)
  static class Body {
    protected new() { /* used for JSON load only */ }
    new(String secret, Map<String, String> mode) {
      this.secret = secret
      this.mode = mode
    }
    
    @Accessors(PUBLIC_GETTER) var String secret
    @Accessors(PUBLIC_GETTER) var Map<String, String> mode
  }
}