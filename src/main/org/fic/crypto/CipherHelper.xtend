package org.fic.crypto

import java.security.PrivateKey
import java.security.PublicKey
import java.security.SecureRandom
import java.util.Arrays
import java.util.Map
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.crypto.KeyLoaderHelper

import static extension org.fic.crypto.Base64Helper.*

@FinalFieldsConstructor
class SecretInfo {
  public val String secret
  public val Map<String, String> mode
}

class CipherHelper {
  val String cipherName
  val SecretKeySpec skeySpec
  
  new(byte[] key) { this("AES/CBC/PKCS5PADDING", key) }
  new(String cipherName, byte[] key) {
    this.cipherName = cipherName
    skeySpec = new SecretKeySpec(key, "AES")
  }
  
  def randomBytes(int number) {
    val random = new SecureRandom
    val keyBytes = newByteArrayOfSize(number)
    random.nextBytes(keyBytes)
    
    return keyBytes
  }
  
  def encrypt(byte[] initVector, String plaintext) {
    val iv = new IvParameterSpec(initVector)
  
    val cipher = Cipher.getInstance(cipherName)
    cipher.init(Cipher.ENCRYPT_MODE, skeySpec, iv)
  
    return cipher.doFinal(plaintext.bytes)
  }
  
  def String decrypt(byte[] initVector, byte[] encrypted) {
    val iv = new IvParameterSpec(initVector)
  
    val cipher = Cipher.getInstance(cipherName)
    cipher.init(Cipher.DECRYPT_MODE, skeySpec, iv)
  
    return new String(cipher.doFinal(encrypted), "UTF-8")
  }
  
  static def SecretInfo createSecret(String nonce, PrivateKey prvKey, PublicKey pubKey) {
    //create secret...
    val sharedKey = DiffieHellmanHelper.keyAgreement(prvKey, pubKey)
    val sKey = Arrays.copyOfRange(sharedKey, 0, 16)
    
    val cipherHelper = new CipherHelper(sKey)
    
    val iv = cipherHelper.randomBytes(16)
    val secret = cipherHelper.encrypt(iv, nonce).encode
    
    //create mode...
    val mode = #{ "df" -> "ECDH", "suite" -> "AES/CBC/PKCS5PADDING", "curve" -> "secp384r1", "iv" -> iv.encode }
    
    return new SecretInfo(secret, mode)
  }
  
  static def String decodeSecret(SecretInfo info, PrivateKey prvKey, String pubKeyEncoded) {
    val klHelper = new KeyLoaderHelper(info.mode.get("curve"))
    val pubKey = klHelper.loadPublicKey(pubKeyEncoded.decode)
    
    return decodeSecret(info, prvKey, pubKey)
  }
  
  static def String decodeSecret(SecretInfo info, PrivateKey prvKey, PublicKey pubKey) {
    val sharedKey = DiffieHellmanHelper.keyAgreement(prvKey, pubKey)
    val sKey = Arrays.copyOfRange(sharedKey, 0, 16)
    
    val cipherHelper = new CipherHelper(sKey)
    
    val iv = info.mode.get("iv").decode
    val secret = info.secret.decode
    return cipherHelper.decrypt(iv, secret)
  }
}