package org.fic.broker.msg.request

import java.nio.ByteBuffer
import org.fic.broker.msg.FMessage

class ReqRegister extends FMessage {
  new(ByteBuffer cardBlock) {
    super(REGISTER)
    
    data.put("card", cardBlock)
  }
  
  def getCardBlock() { data.get("card") as ByteBuffer }
}