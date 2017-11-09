package org.fic.api

import org.fic.JsonDynamicProfile
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class CardTrustedLink extends JsonBase {
  val String version = "1.0"
  
  String url
  
  static def fromJson(String json) {
    JsonDynamicProfile.deserialize(CardTrustedLink, json)
  }
}