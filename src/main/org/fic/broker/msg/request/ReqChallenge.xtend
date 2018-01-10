package org.fic.broker.msg.request

import org.fic.broker.msg.FMessage
import org.fic.broker.msg.SecretStruct

class ReqChallenge extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String phase, SecretStruct secret, String block) {
    super(REQUEST, CHALLENGE, from, to)
    
    body.put("phase", phase)
    body.put("secret", secret)
    body.put("block", block)
  }
  
  def getPhase() { body.get("phase") as String }
  def getSecret() { body.get("secret") as SecretStruct }
  def getBlock() { body.get("block") as String }
}