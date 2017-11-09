package org.fic.api

import com.fasterxml.jackson.annotation.JsonIgnore
import java.security.PrivateKey
import java.util.ArrayList
import java.util.HashMap
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.EllipticCurveHelper
import org.fic.JsonDynamicProfile

import static extension org.fic.EllipticCurveHelper.*

@FinalFieldsConstructor
class CardBlock extends JsonBase {
  @JsonIgnore val ecHelper = new EllipticCurveHelper
  
  @JsonIgnore var locked = false // locked == true means no change can be saved
  @JsonIgnore var String signature // base64 signature
  
  public val String version = "1.0"
  
  // (name, uuid, key) is always unique
  public val String name
  public val String uuid
  public val String key //base-64 encoded public key
  
  //additional card info attributes 
  public val attributes = new HashMap<String, Object>
  public val trustedLinks = new ArrayList<CardTrustedLink>
  
  def sign(PrivateKey prvKey) {
    if (locked)
      throw new RuntimeException("Can't sign CardBlock. It's already blocked.")
    
    locked = true
    signature = ecHelper.doECDSA(prvKey, toJson).encode
    if (verifySignature)
      throw new RuntimeException("Failed in signature verification!")
  }
  
  def verifySignature() {
    val pubKey = ecHelper.loadPublicKey(key.decode)
    ecHelper.verifyECDSA(pubKey, toJson, signature.decode)
  }
  
  static def fromJson(String json) {
    JsonDynamicProfile.deserialize(CardBlock, json)
    
    //verify signature
  }
}