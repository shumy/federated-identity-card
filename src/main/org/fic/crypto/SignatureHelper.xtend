package org.fic.crypto

import java.security.PrivateKey
import java.security.PublicKey
import java.security.Signature
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.api.CryptoContext

import static extension org.fic.crypto.Base64Helper.*

@FinalFieldsConstructor
class SignatureHelper {
  public val String sigName
  
  new() { this(CryptoContext.ctx.signName) }
  
  def sign(PrivateKey prvKey, String plaintext) {
    return sign(prvKey, plaintext.bytes).encode
  }
  
  def sign(PrivateKey prvKey, byte[] plaintext) {
    val dsa = Signature.getInstance(sigName, "BC")
    dsa.initSign(prvKey)
    dsa.update(plaintext)
    
    return dsa.sign
  }
  
  def verifySignature(PublicKey pubKey, String plaintext, String signature) {
    return verifySignature(pubKey, plaintext.bytes, signature.decode)
  }
  
  def verifySignature(PublicKey pubKey, byte[] plaintext, byte[] signature) {  
    val dsaVerify = Signature.getInstance(sigName, "BC")
    dsaVerify.initVerify(pubKey)
    dsaVerify.update(plaintext)
    
    return dsaVerify.verify(signature)
  }
}