package org.fic.api

import com.fasterxml.jackson.databind.ObjectMapper

class JsonBase {
  static protected val mapper = new ObjectMapper
  
  def String toJson() {
    mapper.writeValueAsString(this)
  }
}