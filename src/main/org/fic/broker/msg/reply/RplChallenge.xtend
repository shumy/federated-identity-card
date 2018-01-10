package org.fic.broker.msg.reply

import org.fic.broker.msg.FMessage

class RplChallenge extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String sigChallenge) {
    super(REPLY, CHALLENGE, from, to)
    
    body.put("sigc", sigChallenge)
  }
  
  def getSignedChallenge() { body.get("sigc") as String } //base-64 signed challenge
}