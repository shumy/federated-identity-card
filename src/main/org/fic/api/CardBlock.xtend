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
import org.fic.crypto.KeyLoaderHelper
import org.fic.crypto.SignatureHelper

import static extension org.fic.crypto.Base64Helper.*
import static extension org.fic.crypto.KeyLoaderHelper.*

class CardBlock extends JsonBase {
  @JsonIgnore var sealed = false    // sealed == true means the card is sealed from changes
  
  @JsonIgnore var SignatureHelper signHelper
  @JsonIgnore var KeyLoaderHelper keyLoaderHelper
  
  @JsonIgnore var byte[] signature  // signature
  @JsonIgnore var PublicKey pubKey  // public key
  
  @Accessors(PUBLIC_GETTER) var Map<String, String> header
  
  // (uuid, name, key) is always unique
  @Accessors(PUBLIC_GETTER) var String uuid // UUID.randomUUID.toString
  @Accessors(PUBLIC_GETTER) var String name // the public card name (can be a user name)
  @Accessors(PUBLIC_GETTER) var String key  // base-64 encoded public key
  
  //additional card info attributes 
  @Accessors(PUBLIC_GETTER) var Map<String, Object> info
  @Accessors(PUBLIC_GETTER) var List<CardTrustedLink> links
  
  // creating new card block
  private new() { /* used for JSON load only */ }
  
  new(String name, PublicKey pubKey) {
    this(name, pubKey, "prime256v1", "SHA256withECDSA")
  }
  
  new(String name, PublicKey pubKey, String curveName, String signName) {
    this.signHelper = new SignatureHelper(signName)
    this.header = new HashMap<String, String> => [
      put("version",  "1.0")
      put("curve", curveName)
      put("sign", signName)
    ]
    
    this.pubKey = pubKey
    
    this.uuid = UUID.randomUUID.toString
    this.name = name
    this.key = pubKey.keyToBytes.encode
    
    this.info = new HashMap<String, Object>
    this.links = new ArrayList<CardTrustedLink>
  }
  
  def void sign(PrivateKey prvKey) {
    if (sealed)
      throw new RuntimeException("Can't sign CardBlock. It's already sealed.")
    
    val rawJson = toJson.getBytes("UTF-8")
    sealed = true
    signature = signHelper.sign(prvKey, rawJson)
    
    val isOk = signHelper.verifySignature(pubKey, rawJson, signature)
    if (!isOk)
      throw new RuntimeException("Failed in signature verification! On signing card.")
  }
  
  @JsonIgnore
  def isSignOk() {
    if (!sealed)
      throw new RuntimeException("Can't verify signature. It's not sealed!")
    
    return signHelper.verifySignature(pubKey, toJson.getBytes("UTF-8"), signature)
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
    
    val rawJson = newByteArrayOfSize(data.int)
    data.get(rawJson)
    val json = new String(rawJson, "UTF-8")
    
    // load into object
    return mapper.readValue(json, CardBlock) => [
      keyLoaderHelper = new KeyLoaderHelper(header.get("curve"))
      signHelper = new SignatureHelper(header.get("sign"))
      
      pubKey = keyLoaderHelper.loadPublicKey(key.decode)
      signature = newByteArrayOfSize(data.remaining)
      data.get(signature)
      
      sealed = true
      if (!isSignOk)
        throw new RuntimeException("Failed in signature verification! On loading card data.")
    ]
  }
}