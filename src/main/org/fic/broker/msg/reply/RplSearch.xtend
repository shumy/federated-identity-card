package org.fic.broker.msg.reply

import org.fic.broker.msg.FMessage
import org.eclipse.xtend.lib.annotations.Accessors
import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include
import java.util.Map
import java.util.List

class RplSearch extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to, List<Map<String, String>> result) {
    super(REPLY, SEARCH, from, to)
    this.body = new Body(result)
  }
  
  @Accessors(PUBLIC_GETTER) var Body body
  
  @JsonInclude(Include.NON_NULL)
  static class Body {
    protected new() { /* used for JSON load only */ }
    new(List<Map<String, String>> result) {
      this.result = result
    }
    
    @Accessors(PUBLIC_GETTER) var List<Map<String, String>> result
  }
}