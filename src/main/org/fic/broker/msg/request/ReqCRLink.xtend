package org.fic.broker.msg.request

import org.fic.broker.msg.FMessage

class ReqCRLink extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to) {
    super(REQUEST, CR_LINK, from, to)
    
  }
}