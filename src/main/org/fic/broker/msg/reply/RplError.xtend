package org.fic.broker.msg.reply

import org.fic.broker.msg.FMessage

class RplError extends FMessage {
  //error codes:
  public static val UNKNOWN = "unk"                 //e.g for internal server errors
  public static val TIMEOUT = "tout"                //for reply timeouts
  public static val INVALID_SIGNATURE = "inv-sig"   //e.g for a challenge reply with an invalid signature
  
  new(String code, String message) {
    super(REPLY_ERROR)
    
    data.put("code", code)
    data.put("msg", message)
  }
  
  def getCode() { data.get("code") as String }
  def getMessage() { data.get("msg") as String }
}