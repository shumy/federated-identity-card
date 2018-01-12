package org.fic.broker.msg.request

import org.fic.broker.msg.FMessage
import org.eclipse.xtend.lib.annotations.Accessors
import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include

class ReqSearch extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String query) {
    super(REQUEST, SEARCH, from, null)
    this.body = new Body(query) 
  }
  
  @Accessors(PUBLIC_GETTER) var Body body
  
  @JsonInclude(Include.NON_NULL)
  static class Body {
    protected new() { /* used for JSON load only */ }
    new(String query) {
      this.query = query
    }
    
    @Accessors(PUBLIC_GETTER) var String query
  }
}