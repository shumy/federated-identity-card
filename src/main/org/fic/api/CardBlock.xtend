package org.fic.api

import java.util.HashMap
import java.util.ArrayList

class CardBlock {
  // (name, uuid, key) is always unique
  String name
  String uuid
  String key //base-64 encoded public key
  
  //additional card info attributes 
  val attributes = new HashMap<String, String>
  val trustedLinks = new ArrayList<CardTrustedLink>
  
  //TODO: toJSONString / fromJSONString
  
}