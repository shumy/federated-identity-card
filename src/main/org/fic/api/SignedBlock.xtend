package org.fic.api

import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.databind.ObjectMapper
import java.nio.ByteBuffer
import java.security.PrivateKey
import java.security.PublicKey
import java.util.HashMap
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.crypto.KeyLoaderHelper
import org.fic.crypto.SignatureHelper

import static extension org.fic.crypto.Base64Helper.*
import static extension org.fic.crypto.KeyLoaderHelper.*

class SignedBlock {
  public static val mapper = new ObjectMapper
  
  @JsonIgnore var SignatureHelper signHelper
  @JsonIgnore var KeyLoaderHelper keyLoaderHelper
  
  @JsonIgnore @Accessors(PUBLIC_GETTER) var signed = false  // signed == true means the card is sealed from changes
  @JsonIgnore var byte[] signature  // signature
  @JsonIgnore var PublicKey pubKey  // public key
  
  @Accessors(PUBLIC_GETTER) var Map<String, String> header
  @Accessors(PUBLIC_GETTER) var String key
  
  protected new() { /* used for JSON load only */ }
  
  new(PublicKey pubKey, String curveName, String signName) {
    this.signHelper = new SignatureHelper(signName)
    this.header = new HashMap<String, String> => [
      put("version",  "1.0")
      put("curve", curveName)
      put("sign", signName)
    ]
    
    this.pubKey = pubKey
    this.key = pubKey.keyToBytes.encode
  }
  
  def void sign(PrivateKey prvKey) {
    if (signed)
      throw new FicError(SignedBlock, "Can't sign CardBlock. It's already signed.", 1)
    
    val rawJson = jsonData
    signature = signHelper.sign(prvKey, rawJson)
    
    val isOk = signHelper.verifySignature(pubKey, rawJson, signature)
    if (!isOk)
      throw new FicError(SignedBlock, "Failed in signature verification! On signing card.", 2)
    
    signed = true
  }
  
  def ByteBuffer retrieve() {
    if (!signed)
      throw new FicError(SignedBlock, "Failed in signature verification! On retrieving data.", 3)
    
    val rawJson = jsonData
    val bufSize = 4 + rawJson.length + signature.length
    
    return ByteBuffer.allocate(bufSize) => [
      putInt(rawJson.length)
      put(rawJson)
      put(signature)
      flip
    ]
  }
  
  protected static def <T extends SignedBlock> T load(Class<T> type, ByteBuffer data) {
    val rawJson = newByteArrayOfSize(data.int)
    data.get(rawJson)
    val json = new String(rawJson, "UTF-8")
    
    return mapper.readValue(json, type) => [
      val t = it as SignedBlock
      
      t.keyLoaderHelper = new KeyLoaderHelper(t.header.get("curve"))
      t.signHelper = new SignatureHelper(t.header.get("sign"))
      
      t.pubKey = t.keyLoaderHelper.loadPublicKey(t.key.decode)
      t.signature = newByteArrayOfSize(data.remaining)
      data.get(t.signature)
      
      val isOk = t.signHelper.verifySignature(t.pubKey, rawJson, t.signature)
      if (!isOk)
        throw new FicError(SignedBlock, "Failed in signature verification! On loading data.", 4)
      
      t.signed = true
    ]
  }
  
  def toJson() {
    mapper.writerWithDefaultPrettyPrinter.writeValueAsString(this)
  }
  
  private def jsonData() {
    mapper.writeValueAsString(this).getBytes("UTF-8")
  }
}