package org.fic.broker.msg.request

import java.nio.ByteBuffer
import org.fic.broker.msg.FMessage

class ReqRegister extends FMessage {
  public static val NEW = "new"
  public static val CANDIDATE = "cand"
  
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String reqType, ByteBuffer cardBlock) {
    super(REQUEST, REGISTER, from, to)
    
    body.put("type", reqType)
    body.put("card", cardBlock)
  }
  
  def getRequestType() { body.get("type") as String }
  def getCardBlock() { body.get("card") as ByteBuffer }
}