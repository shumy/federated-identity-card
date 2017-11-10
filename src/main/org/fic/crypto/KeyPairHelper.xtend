package org.fic.crypto

import java.security.KeyPairGenerator
import java.security.SecureRandom
import org.bouncycastle.jce.ECNamedCurveTable
import org.bouncycastle.jce.spec.ECNamedCurveParameterSpec

class KeyPairHelper {
  val ECNamedCurveParameterSpec ecSpec
  val KeyPairGenerator kpg
  
  new() { this("prime256v1") }
  new(String curveName) {
    ecSpec = ECNamedCurveTable.getParameterSpec(curveName)
    
    kpg = KeyPairGenerator.getInstance("EC", "BC")
    kpg.initialize(ecSpec, new SecureRandom)
  }
  
  def genKeyPair() { kpg.generateKeyPair }
}