package org.fic.api

import com.fasterxml.jackson.annotation.JsonIgnore
import java.nio.ByteBuffer
import java.security.PrivateKey
import java.security.PublicKey
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.EllipticCurveHelper

import static extension org.fic.EllipticCurveHelper.*

class CardBlock extends JsonBase {
  public static val ecHelper = new EllipticCurveHelper
  
  @JsonIgnore var sealed = false    // sealed == true means the card is sealed from changes
  @JsonIgnore var byte[] signature  // signature
  @JsonIgnore var PublicKey pubKey  // public key
  
  public val String version = "1.0"
  
  // (uuid, name, key) is always unique
  @Accessors(PUBLIC_GETTER) var String uuid // UUID.randomUUID.toString
  @Accessors(PUBLIC_GETTER) var String name // the public card name (can be a user name)
  @Accessors(PUBLIC_GETTER) var String key  // base-64 encoded public key
  
  //additional card info attributes 
  @Accessors(PUBLIC_GETTER) var Map<String, Object> attributes
  @Accessors(PUBLIC_GETTER) var List<CardTrustedLink> trustedLinks
  
  // creating new card block
  private new() { /* used for JSON load only */}
  new(String name, PublicKey pubKey) {
    this.pubKey = pubKey
    
    this.uuid = UUID.randomUUID.toString
    this.name = name
    this.key = pubKey.keyToBytes.encode
    
    this.attributes = new HashMap<String, Object>
    this.trustedLinks = new ArrayList<CardTrustedLink>
  }
  
  def void sign(PrivateKey prvKey) {
    if (sealed)
      throw new RuntimeException("Can't sign CardBlock. It's already sealed.")
    
    val rawJson = toJson.getBytes("UTF-8")
    sealed = true
    signature = ecHelper.doECDSA(prvKey, rawJson)
    
    val isOk = ecHelper.verifyECDSA(pubKey, rawJson, signature)
    if (!isOk)
      throw new RuntimeException("Failed in signature verification! On signing card.")
  }
  
  @JsonIgnore
  def isSignOk() {
    if (!sealed)
      throw new RuntimeException("Can't verify signature. It's not sealed!")
    
    return ecHelper.verifyECDSA(pubKey, toJson.getBytes("UTF-8"), signature)
  }
  
  def ByteBuffer retrieve() {
    if (!isSignOk)
      throw new RuntimeException("Failed in signature verification! On retrieving card data.")
    
    val rawJson = toJson.getBytes("UTF-8")
    val bufSize = 4 + rawJson.length + signature.length
    
    return ByteBuffer.allocate(bufSize) => [
      putInt(rawJson.length)
      put(rawJson)
      put(signature)
      flip
    ]
  }
  
  static def CardBlock load(ByteBuffer data) {
    /* structure
     * int -> size of json struct
     * <size> -> json data in UTF-8
     * <rest> -> signature
     */
    
    // load json
    val rawJson = newByteArrayOfSize(data.int)
    data.get(rawJson)
    val json = new String(rawJson, "UTF-8")
    
    // load into object
    val card = mapper.readValue(json, CardBlock)
    card.pubKey = ecHelper.loadPublicKey(card.key.decode)
    
    // load signature
    card.signature = newByteArrayOfSize(data.remaining)
    data.get(card.signature)
    
    card.sealed = true
    if (!card.isSignOk)
      throw new RuntimeException("Failed in signature verification! On loading card data.")
    
    return card
  }
}