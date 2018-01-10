package org.fic.broker.msg.reply

import org.fic.broker.msg.FMessage

class RplSearch extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String result) {
    super(REPLY, SEARCH, from, to)
    
    body.put("result", result)
  }
  
  def getResult() { body.get("result") as String }
}