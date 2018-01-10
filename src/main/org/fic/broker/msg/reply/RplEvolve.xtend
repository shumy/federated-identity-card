package org.fic.broker.msg.reply

import org.fic.broker.msg.FMessage
import org.fic.broker.msg.ChainStruct

class RplEvolve extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to, ChainStruct[] chain) {
    super(REPLY, EVOLVE, from, to)
    
    body.put("chain", chain)
  }
  
  def getChain() { body.get("chain") as ChainStruct[] }
}