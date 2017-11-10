package org.fic.crypto

import org.bouncycastle.jce.spec.ECPublicKeySpec
import java.security.KeyFactory
import org.bouncycastle.jce.spec.ECPrivateKeySpec
import java.math.BigInteger
import java.security.PublicKey
import java.security.PrivateKey
import org.bouncycastle.jce.interfaces.ECPrivateKey
import org.bouncycastle.jce.interfaces.ECPublicKey
import org.bouncycastle.jce.spec.ECNamedCurveParameterSpec
import org.bouncycastle.jce.ECNamedCurveTable

class KeyLoaderHelper {
  val ECNamedCurveParameterSpec ecSpec
  
  new(String curveName) {
    ecSpec = ECNamedCurveTable.getParameterSpec(curveName)
  }
  
  def loadPublicKey(byte[] data) {
    val pubKey = new ECPublicKeySpec(ecSpec.curve.decodePoint(data), ecSpec)
    val kf = KeyFactory.getInstance("ECDH", "BC")
    
    return kf.generatePublic(pubKey)
  }
  
  def loadPrivateKey(byte[] data) {
    val prvkey = new ECPrivateKeySpec(new BigInteger(data), ecSpec)
    val kf = KeyFactory.getInstance("ECDH", "BC")
    
    return kf.generatePrivate(prvkey)
  }
  
  def static keyToBytes(PublicKey key) {
    val eckey = key as ECPublicKey
    return eckey.q.getEncoded(true)
  }
  
  def static keyToBytes(PrivateKey key) {
    val eckey = key as ECPrivateKey 
    return eckey.d.toByteArray
  }
}