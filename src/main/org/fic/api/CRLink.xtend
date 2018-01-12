package org.fic.api

import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include
import java.nio.ByteBuffer
import java.security.PublicKey
import org.eclipse.xtend.lib.annotations.Accessors

// Cancel / Recover
@JsonInclude(Include.NON_NULL)
class CRLink extends SignedBlock {
  public static val CANCEL = 1
  public static val RECOVER = 2
  
  @Accessors(PUBLIC_GETTER) var int type
  @Accessors(PUBLIC_GETTER) var String uuid         // reference to the registration card (confirming that the RRLink is for the CardChain)
  @Accessors(PUBLIC_GETTER) var String prev         // reference to the revoked card
  @Accessors(PUBLIC_GETTER) var String next = null  // reference to the recovered card, non existent on revoke
  
  private new() { /* used for JSON load only */ }
  private new(PublicKey pubKey, String curveName, String signName) {
    super(pubKey, curveName, signName)
  }
  
  static def newCancel(PublicKey pubKey, String uuidCard, String prevCard) {
    CRLink.newCancel(pubKey, uuidCard, prevCard, CryptoContext.ctx.curveName, CryptoContext.ctx.signName)
  }
  
  static def newCancel(PublicKey pubKey, String uuidCard, String prevCard, String curveName, String signName) {
    return new CRLink(pubKey, curveName, signName) => [
      type = CRLink.CANCEL
      uuid = uuidCard
      prev = prevCard
    ]
  }
  
  static def newRecover(PublicKey pubKey, String regLink, String prevCard, String nextCard) {
    CRLink.newRecover(pubKey, regLink, prevCard, nextCard, CryptoContext.ctx.curveName, CryptoContext.ctx.signName)
  }
  
  static def newRecover(PublicKey pubKey, String uuidCard, String prevCard, String nextCard, String curveName, String signName) {
    return new CRLink(pubKey, curveName, signName) => [
      type = CRLink.RECOVER
      uuid = uuidCard
      prev = prevCard
      next = nextCard
    ]
  }
  
  static def newCancelAndRecover(PublicKey pubKey, String regLink, String prevCard, String nextCard) {
    CRLink.newCancelAndRecover(pubKey, regLink, prevCard, nextCard, "prime256v1", "SHA256withECDSA")
  }
  
  static def newCancelAndRecover(PublicKey pubKey, String uuidCard, String prevCard, String nextCard, String curveName, String signName) {
    return new CRLink(pubKey, curveName, signName) => [
      type = CRLink.CANCEL.bitwiseOr(CRLink.RECOVER)
      uuid = uuidCard
      prev = prevCard
      next = nextCard
    ]
  }
  
  static def load(ByteBuffer data) { SignedBlock.load(CRLink, data) }
}
