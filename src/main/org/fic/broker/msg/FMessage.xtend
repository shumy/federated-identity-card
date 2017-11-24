package org.fic.broker.msg

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import java.util.HashMap

@FinalFieldsConstructor
abstract class FMessage {
  //message types:
  public static val REPLY_ERROR = "rpl-error"
  
  public static val CHALLENGE = "req-cha"
  public static val REPLY_CHALLENGE = "rpl-cha"
  
  public static val REGISTER = "req-reg"
  
  
  public val String version = "1.0"
  public val String type
  
  //data with 1 level layer. Not a tree...
  protected val data = new HashMap<String, Object>
}