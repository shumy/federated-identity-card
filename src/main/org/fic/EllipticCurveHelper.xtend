package org.fic

import com.google.common.io.BaseEncoding
import java.math.BigInteger
import java.security.KeyFactory
import java.security.KeyPairGenerator
import java.security.PrivateKey
import java.security.PublicKey
import java.security.SecureRandom
import java.security.Security
import java.security.Signature
import javax.crypto.KeyAgreement
import org.bouncycastle.jce.ECNamedCurveTable
import org.bouncycastle.jce.interfaces.ECPrivateKey
import org.bouncycastle.jce.interfaces.ECPublicKey
import org.bouncycastle.jce.provider.BouncyCastleProvider
import org.bouncycastle.jce.spec.ECNamedCurveParameterSpec
import org.bouncycastle.jce.spec.ECPrivateKeySpec
import org.bouncycastle.jce.spec.ECPublicKeySpec

class EllipticCurveHelper {
  val static b64Codec = BaseEncoding.base64
  
  val String sigName
  val ECNamedCurveParameterSpec ecSpec
  val KeyPairGenerator kpg
  
  new() { this("prime256v1", "SHA256withECDSA") }
  new(String curveName, String sigName) {
    Security.addProvider(new BouncyCastleProvider)
    
    this.sigName = sigName
    ecSpec = ECNamedCurveTable.getParameterSpec(curveName)
    
    kpg = KeyPairGenerator.getInstance("EC", "BC")
    kpg.initialize(ecSpec, new SecureRandom)
  }
  
  def generateKeyPair() { kpg.generateKeyPair }
  
  def doECDH(PrivateKey prvKey, PublicKey pubKey) {
    val ka = KeyAgreement.getInstance("ECDH", "BC")
    ka.init(prvKey)
    ka.doPhase(pubKey, true)
    
    return ka.generateSecret
  }
  
  def doECDSA(PrivateKey prvKey, byte[] plaintext) {
    //val strByte = plaintext.getBytes("UTF-8")
    
    val dsa = Signature.getInstance(sigName, "BC")
    dsa.initSign(prvKey)
    dsa.update(plaintext)
    
    return dsa.sign
  }
  
  def verifyECDSA(PublicKey pubKey, byte[] plaintext, byte[] signature) {
    //val strByte = plaintext.getBytes("UTF-8")
    
    val dsaVerify = Signature.getInstance(sigName, "BC")
    dsaVerify.initVerify(pubKey)
    dsaVerify.update(plaintext)
    
    return dsaVerify.verify(signature)
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
  
  def static encode(byte[] bytes) {
    b64Codec.encode(bytes)
  }
  
  def static decode(String data) {
    b64Codec.decode(data)
  }
}