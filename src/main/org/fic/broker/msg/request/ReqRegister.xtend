package org.fic.broker.msg.request

import java.nio.ByteBuffer
import org.fic.broker.msg.FMessage

class ReqRegister extends FMessage {
  public static val NEW = "new"
  public static val CANDIDATE = "cand"
  
  new(String type, ByteBuffer cardBlock) {
    super(REGISTER)
    
    data.put("type", type)
    data.put("card", cardBlock)
  }
  
  def getType() { data.get("type") as String }
  def getCardBlock() { data.get("card") as ByteBuffer }
}