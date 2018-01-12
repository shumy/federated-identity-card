package org.fic.broker.msg.request

import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.broker.msg.FMessage

class ReqEvolve extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String uuid, String start) {
    super(REQUEST, EVOLVE, from, null)
    this.body = new Body(uuid, start) 
  }
  
  @Accessors(PUBLIC_GETTER) var Body body
  
  @JsonInclude(Include.NON_NULL)
  static class Body {
    protected new() { /* used for JSON load only */ }
    new(String uuid, String start) {
      this.uuid = uuid
      this.start = start
    }
    
    @Accessors(PUBLIC_GETTER) var String uuid
    @Accessors(PUBLIC_GETTER) var String start
  }
}