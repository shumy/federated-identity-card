package org.fic.api

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonProperty
import java.security.PublicKey
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Accessors
import java.nio.ByteBuffer

class TrustedLink {
  public val String url // url where the Revoke/Recover protocol is available
  
  // identification of the trusted link
  public val String uuid
  public val String key
  
  //TODO: link options (exclusive, mandatory, ...)
  
  @JsonCreator new(
    @JsonProperty("url") String url,
    @JsonProperty("uuid") String uuid,
    @JsonProperty("key") String key
  ) {
    this.url = url
    this.uuid = uuid
    this.key = key
  }
}

class CardBlock extends SignedBlock {
  // (uuid, name, key) is always unique
  @Accessors(PUBLIC_GETTER) var String uuid // UUID.randomUUID.toString
  
  //additional card info attributes 
  @Accessors(PUBLIC_GETTER) var Map<String, Object> info // other public information
  @Accessors(PUBLIC_GETTER) var List<TrustedLink> links
  
  private new() { /* used for JSON load only */ }
  new(PublicKey pubKey) { this(pubKey, "prime256v1", "SHA256withECDSA") }
  
  new(PublicKey pubKey, String curveName, String signName) {
    super(pubKey, curveName, signName)
    
    this.uuid = UUID.randomUUID.toString
    
    this.info = new HashMap<String, Object>
    this.links = new ArrayList<TrustedLink>
  }
  
  static def load(ByteBuffer data) { SignedBlock.load(CardBlock, data) }
}