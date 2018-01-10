package org.fic.broker.msg.request

import org.fic.broker.msg.FMessage

class ReqSubscribe extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to) {
    super(REQUEST, SUBSCRIBE, from, to)
  }
}