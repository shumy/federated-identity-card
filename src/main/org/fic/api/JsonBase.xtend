package org.fic.api

import org.fic.JsonDynamicProfile

class JsonBase {
  def String toJson() {
    JsonDynamicProfile.serialize(this)
  }
}