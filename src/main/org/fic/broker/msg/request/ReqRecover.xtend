package org.fic.broker.msg.request

import org.fic.broker.msg.FMessage

class ReqRecover extends FMessage {
  new(String uuid, String candidateKey) {
    super(RECOVER)
    
    data.put("key", candidateKey)
  }
  
  //base-64 new candidate key
  def getCandidateKey() { data.get("key") as String }
}