package org.fic.broker.msg.request

import org.fic.broker.msg.FMessage

class ReqChallenge extends FMessage {
  new(String key, String challenge) {
    super(CHALLENGE)
    
    data.put("key", key)
    data.put("chl", challenge)
  }
  
  def getKey() { data.get("key") as String }
  def getChallenge() { data.get("chl") as String }
}