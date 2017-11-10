package org.fic.api

import com.fasterxml.jackson.annotation.JsonIgnore
import java.util.List
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import java.nio.ByteBuffer
import java.security.PublicKey

class RRLink extends SignedBlock {
  private new() { /* used for JSON load only */ }
  new(PublicKey pubKey) { this(pubKey, "prime256v1", "SHA256withECDSA") }
  
  new(PublicKey pubKey, String curveName, String signName) {
    super(pubKey, curveName, signName)
  }
  
  static def load(ByteBuffer data) { SignedBlock.load(RRLink, data) }
}

@FinalFieldsConstructor
class CardChain {
  // identification of the initial card
  public val String uuid
  public val String name
  public val String key
  
  public val List<CardBlock> chain
  
  def addLink(RRLink link) {
    //TODO: verify the status of the chain
    //TODO: verify signature of the revoke/recover link
  }
  
  // validate the complete chain, signatures of cards and links
  @JsonIgnore
  def isValid() {
    
  }
}