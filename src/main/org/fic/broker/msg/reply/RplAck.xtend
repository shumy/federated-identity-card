package org.fic.broker.msg.reply

import org.fic.broker.msg.FMessage

class RplAck extends FMessage {
  //reply with success:
  public static val OK = "ok"                       //OK ack
  
  //reply error codes:
  public static val UNKNOWN = "unk"                 //e.g for internal server errors
  public static val TIMEOUT = "tout"                //for reply timeouts
  
  public static val CANCELED_KEY = "cnl-key"        //e.g for a challenge reply with an canceled card key
  public static val INVALID_SIGNATURE = "inv-sig"   //e.g for a challenge reply with an invalid signature
  
  new(String code, String message) {
    super(ACK)
    
    data.put("code", code)
    data.put("msg", message)
  }
  
  def getCode() { data.get("code") as String }
  def getMessage() { data.get("msg") as String }
}