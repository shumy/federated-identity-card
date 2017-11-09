package org.fic.api

import com.fasterxml.jackson.annotation.JsonIgnore
import java.security.PrivateKey
import java.util.ArrayList
import java.util.HashMap
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.EllipticCurveHelper
import org.fic.JsonDynamicProfile

import static extension org.fic.EllipticCurveHelper.*
import java.util.UUID

@FinalFieldsConstructor
class CardBlock extends JsonBase {
  @JsonIgnore val ecHelper = new EllipticCurveHelper
  
  @JsonIgnore var sealed = false // sealed == true means the card is sealed from changes.
  @JsonIgnore var String signature // base-64 encoded signature
  
  public val String version = "1.0"
  
  // (uuid, name, key) is always unique
  public val String uuid = UUID.randomUUID.toString
  public val String name // the public card name (can be a user name)
  public val String key // base-64 encoded public key
  
  //additional card info attributes 
  public val attributes = new HashMap<String, Object>
  public val trustedLinks = new ArrayList<CardTrustedLink>
  
  def void sign(PrivateKey prvKey) {
    if (sealed)
      throw new RuntimeException("Can't sign CardBlock. It's already sealed.")
    
    sealed = true
    signature = ecHelper.doECDSA(prvKey, toJson).encode
    if (verifySignature)
      throw new RuntimeException("Failed in signature verification!")
  }
  
  def verifySignature() {
    if (!sealed)
      throw new RuntimeException("Can't verify signature. It's not sealed!")
      
    val pubKey = ecHelper.loadPublicKey(key.decode)
    return ecHelper.verifyECDSA(pubKey, toJson, signature.decode)
  }
  
  static def fromJson(String json) {
    val card = JsonDynamicProfile.deserialize(CardBlock, json)
    card.verifySignature
    
    return card
  }
}