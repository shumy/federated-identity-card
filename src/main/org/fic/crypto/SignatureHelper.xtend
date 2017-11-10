package org.fic.crypto

import java.security.PrivateKey
import java.security.PublicKey
import java.security.Signature
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class SignatureHelper {
  val String sigName
  
  new() { this("SHA256withECDSA") }
  
  def sign(PrivateKey prvKey, byte[] plaintext) {
    val dsa = Signature.getInstance(sigName, "BC")
    dsa.initSign(prvKey)
    dsa.update(plaintext)
    
    return dsa.sign
  }
  
  def verifySignature(PublicKey pubKey, byte[] plaintext, byte[] signature) {  
    val dsaVerify = Signature.getInstance(sigName, "BC")
    dsaVerify.initVerify(pubKey)
    dsaVerify.update(plaintext)
    
    return dsaVerify.verify(signature)
  }
}