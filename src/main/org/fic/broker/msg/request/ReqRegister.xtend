package org.fic.broker.msg.request

import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include
import java.nio.ByteBuffer
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.broker.msg.FMessage

class ReqRegister extends FMessage {
  public static val NEW = "new"
  public static val CANDIDATE = "cand"
  
  protected new() { /* used for JSON load only */ }
  new(String from, String reqType, ByteBuffer card) {
    super(REQUEST, REGISTER, from, null)
    this.body = new Body(reqType, card)
  }
  
  @Accessors(PUBLIC_GETTER) var Body body
  
  @JsonInclude(Include.NON_NULL)
  static class Body {
    protected new() { /* used for JSON load only */ }
    new(String type, ByteBuffer card) {
      this.type = type
      this.card = card
    }
    
    @Accessors(PUBLIC_GETTER) var String type
    @Accessors(PUBLIC_GETTER) var ByteBuffer card
  }
}