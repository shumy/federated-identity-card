package org.fic

import javax.crypto.spec.SecretKeySpec
import javax.crypto.spec.IvParameterSpec
import javax.crypto.Cipher

class CipherHelper {
  val String cipherName
  val SecretKeySpec skeySpec
  
  new(byte[] key) { this("AES/CBC/PKCS5PADDING", key) }
  new(String cipherName, byte[] key) {
    this.cipherName = cipherName
    skeySpec = new SecretKeySpec(key, "AES")
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
}