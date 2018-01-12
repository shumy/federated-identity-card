package org.fic.api

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonProperty
import java.nio.ByteBuffer
import java.security.PublicKey
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import com.fasterxml.jackson.annotation.JsonInclude.Include
import com.fasterxml.jackson.annotation.JsonInclude

class TrustedLink {
  public val String url // url where the Revoke/Recover protocol is available
  
  // identification of the trusted link public key. CELink must be signed with this key, or one evolved from it.
  public val String key
  
  //TODO: link options (exclusive, mandatory, authoritative, ...)
  
  @JsonCreator new(
    @JsonProperty("url") String url,
    @JsonProperty("key") String key
  ) {
    this.url = url
    this.key = key
  }
}

@JsonInclude(Include.NON_NULL)
class CardBlock extends SignedBlock {
  @Accessors(PUBLIC_GETTER) var String uuid
  
  //additional card info attributes 
  @Accessors(PUBLIC_GETTER) var Map<String, String> info // other public information
  @Accessors(PUBLIC_GETTER) var List<TrustedLink> links
  
  private new() { /* used for JSON load only */ }
  new(PublicKey pubKey) {
    this(pubKey, null, CryptoContext.ctx.curveName, CryptoContext.ctx.signName)
  }
  
  new(PublicKey pubKey, String uuid) {
    this(pubKey, uuid, CryptoContext.ctx.curveName, CryptoContext.ctx.signName)
  }
  
  new(PublicKey pubKey, String uuid, String curveName, String signName) {
    super(pubKey, curveName, signName)
    
    this.uuid = uuid ?: key
    this.info = new HashMap<String, String>
    this.links = new ArrayList<TrustedLink>
  }
  
  static def load(ByteBuffer data) { SignedBlock.load(CardBlock, data) }
}