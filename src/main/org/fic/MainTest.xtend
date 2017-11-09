package org.fic

import static extension org.fic.EllipticCurveHelper.*
import java.util.Arrays

class MainTest {
  def static void main(String[] args) {
    testECDSA
    
    println("")
    val key = testECDH
    
    println("")
    testAES(key)
  }
  
  def static testAES(byte[] key) {
    val sKey = Arrays.copyOfRange(key, 0, 16)
    val cipherHelper = new CipherHelper(sKey)
    
    val plaintext = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    val iv = cipherHelper.randomBytes(16)
    
    val encrypted = cipherHelper.encrypt(iv, plaintext)
    println('''Encrypt: «plaintext» -> «encrypted.encode»''')
    
    val decrypted = cipherHelper.decrypt(iv, encrypted)
    println('''Decrypt: «encrypted.encode» -> «decrypted»''')
  }
  
  def static testECDH() {
    val ecHelper = new EllipticCurveHelper
    val kp1 = ecHelper.generateKeyPair
    val kp2 = ecHelper.generateKeyPair
    
    val prvAlice = kp1.private
    val pubAlice = kp1.public
    
    val prvBob = kp2.private
    val pubBob = kp2.public
    
    println("Alice")
    println("  Private: " + prvAlice.keyToBytes.encode)
    println("  Public: " + pubAlice.keyToBytes.encode)
    
    println("Bob")
    println("  Private: " + prvBob.keyToBytes.encode)
    println("  Public: " + pubBob.keyToBytes.encode)
        
    //key agreement
    val k1 = ecHelper.doECDH(prvAlice, pubBob)
    val k2 = ecHelper.doECDH(prvBob, pubAlice)
    
    val k1Hex = k1.encode
    val k2Hex = k2.encode
    
    println("")
    println('''  Secret Key («k1.length» bytes): «k1Hex»''')
    println("  Key Agreement OK => " + (k1Hex == k2Hex))
    
    return k1
  }
  
  def static testECDSA() {
    val ecHelper = new EllipticCurveHelper
    val kp1 = ecHelper.generateKeyPair
    val kp2 = ecHelper.generateKeyPair
    
    val prvAlice = kp1.private
    val pubAlice = kp1.public
    val plaintext = "Signed text for Alice..."
    
    println("Alice")
    println("  PlainText: " + plaintext)
    println("  Private: " + prvAlice.keyToBytes.encode)
    println("  Public: " + pubAlice.keyToBytes.encode)
    
    println("")
    val sig = ecHelper.doECDSA(prvAlice, plaintext)
    println('''  Signature («sig.length» bytes): «sig.encode»''')
    
    val expectedTrue = ecHelper.verifyECDSA(pubAlice, plaintext, sig)
    println("  Signature OK => " + expectedTrue)
    
    val expectedFalse = ecHelper.verifyECDSA(kp2.public, plaintext, sig)
    println("  Signature OK => " + expectedFalse)
  }
}