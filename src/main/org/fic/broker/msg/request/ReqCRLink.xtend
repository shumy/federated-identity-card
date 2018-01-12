package org.fic.broker.msg.request

import org.fic.broker.msg.FMessage
import org.eclipse.xtend.lib.annotations.Accessors
import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include
import java.nio.ByteBuffer

class ReqCRLink extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, ByteBuffer lnk) {
    super(REQUEST, CR_LINK, from, null)
    this.body = new Body(lnk)
  }
  
  @Accessors(PUBLIC_GETTER) var Body body
  
  @JsonInclude(Include.NON_NULL)
  static class Body {
    protected new() { /* used for JSON load only */ }
    new(ByteBuffer lnk) {
      this.lnk = lnk
    }
    
    @Accessors(PUBLIC_GETTER) var ByteBuffer lnk
  }
}