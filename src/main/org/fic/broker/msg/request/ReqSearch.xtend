package org.fic.broker.msg.request

import org.fic.broker.msg.FMessage

class ReqSearch extends FMessage {
  protected new() { /* used for JSON load only */ }
  new(String from, String to, String query) {
    super(REQUEST, SEARCH, from, to)
    
    body.put("query", query)
  }
  
  def getQuery() { body.get("query") as String }
}