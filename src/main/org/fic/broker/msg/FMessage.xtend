package org.fic.broker.msg

import java.util.HashMap
import org.eclipse.xtend.lib.annotations.Accessors

abstract class FMessage {
  // message types:
  public static val REQUEST = "req"
  public static val REPLY = "rpl"
  
  // message commands:
  public static val ACK = "ack"
  
  public static val CHALLENGE = "cha"
  public static val SUBSCRIBE = "sub"
  public static val REGISTER = "reg"
  
  public static val CR = "cr"
  public static val CR_LINK = "cr-lnk"
  
  public static val SEARCH = "sch"
  public static val EVOLVE = "evl"
  
  protected new() { /* used for JSON load only */ }
  new(String type, String cmd, String from, String to) {
    this.type = type
    this.cmd = cmd
    this.from = from
    this.to = to
  }
  
  // message fields:
  public var Long id                                                               //message sequence (set by the broker)
  
  @Accessors(PUBLIC_GETTER) var String ver = "1.0"                                 //protocol version number
  @Accessors(PUBLIC_GETTER) var String type                                        //message identification (request/reply)
  @Accessors(PUBLIC_GETTER) var String cmd                                         //command identification
  
  @Accessors(PUBLIC_GETTER) var String from                                        //origin of the message (public-key)
  @Accessors(PUBLIC_GETTER) var String to                                          //destination of the message (public-key)
  
  //data with 1 level layer. Not a tree...
  protected val body = new HashMap<String, Object>
}