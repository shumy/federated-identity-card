package org.fic.api

import org.fic.JsonDynamicProfile
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class CardChain extends JsonBase {
  val String version = "1.0"
  
  static def fromJson(String json) {
    JsonDynamicProfile.deserialize(CardChain, json)
  }
}