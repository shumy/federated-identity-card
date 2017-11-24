package org.fic.broker.msg.reply

import org.fic.broker.msg.FMessage

class RplChallenge extends FMessage {
  new(String sigChallenge) {
    super(REPLY_CHALLENGE)
    
    data.put("sigc", sigChallenge)
  }
  
  //base-64 signed challenge
  def getSignedChallenge() { data.get("sigc") as String }
}