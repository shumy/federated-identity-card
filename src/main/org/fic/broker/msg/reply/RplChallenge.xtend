package org.fic.broker.msg.reply

import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.broker.msg.FMessage

class RplChallenge extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String sigc) {
    super(REPLY, CHALLENGE, from, to)
    this.body = new Body(sigc)
  }
  
  @Accessors(PUBLIC_GETTER) var Body body
  
  @JsonInclude(Include.NON_NULL)
  static class Body {
    protected new() { /* used for JSON load only */ }
    new(String sigc) {
      this.sigc = sigc
    }
    
    @Accessors(PUBLIC_GETTER) var String sigc
  }
}