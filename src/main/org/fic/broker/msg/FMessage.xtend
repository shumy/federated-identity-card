package org.fic.broker.msg

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import java.util.HashMap

@FinalFieldsConstructor
abstract class FMessage {
  //message types:
  public static val ACK = "ack" //generic reply message (OK, ERROR)
  
  public static val CHALLENGE = "req-cha"
  public static val REPLY_CHALLENGE = "rpl-cha"
  
  public static val REGISTER = "req-reg" //reply with ack
  
  public static val CANCEL = "req-cnl" //reply with ack
  public static val CANCEL_LINK = "req-cnl-lnk" //reply with ack
  
  public static val RECOVER = "req-rec" //reply with ack
  public static val RECOVER_LINK = "req-rec-lnk" //reply with ack
  
  public val String version = "1.0"
  public val String type
  
  //data with 1 level layer. Not a tree...
  protected val data = new HashMap<String, Object>
}