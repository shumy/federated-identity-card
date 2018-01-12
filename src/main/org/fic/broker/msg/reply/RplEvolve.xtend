package org.fic.broker.msg.reply

import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include
import java.nio.ByteBuffer
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.broker.msg.FMessage

import static extension org.fic.crypto.Base64Helper.*
import java.util.List

@JsonInclude(Include.NON_NULL)
class ChainStruct {
  @Accessors(PUBLIC_GETTER) var ByteBuffer card               //encoded CardBlock
  @Accessors(PUBLIC_GETTER) var List<ByteBuffer> links        //encoded CRLink's
  
  protected new() { /* used for JSON load only */ }
  new(ByteBuffer card, List<ByteBuffer> links) {
    this.card = card
    this.links = links
  }
  
  override toString() {
    val cardStr = card.array.encode
    val linksStr = links.fold("")[ r, next |
      r + "." + next.array.encode
    ]
    
    return cardStr + "." + linksStr
  }
}

class RplEvolve extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to, List<ChainStruct> chain, String sign, Map<String, String> mode) {
    super(REPLY, EVOLVE, from, to)
    this.body = new Body(chain, sign, mode)
  }
  
  @Accessors(PUBLIC_GETTER) var Body body
  
  @JsonInclude(Include.NON_NULL)
  static class Body {
    protected new() { /* used for JSON load only */ }
    new(List<ChainStruct> chain, String sign, Map<String, String> mode) {
      this.chain = chain
      this.sign = sign
      this.mode = mode
    }
    
    @Accessors(PUBLIC_GETTER) var List<ChainStruct> chain
    @Accessors(PUBLIC_GETTER) var String sign
    @Accessors(PUBLIC_GETTER) var Map<String, String> mode
  }
}