package org.fic.test

import java.util.Arrays
import org.fic.crypto.CipherHelper
import org.fic.crypto.KeyPairHelper
import org.fic.crypto.SignatureHelper
import org.junit.Assert
import org.junit.Test

import static extension org.fic.crypto.Base64Helper.*
import static extension org.fic.crypto.DiffieHellmanHelper.*
import static extension org.fic.crypto.KeyLoaderHelper.*

class CryptoTest {
  
  @Test
  def void testECDH() {
    val kpHelper = new KeyPairHelper
    val kp1 = kpHelper.genKeyPair
    val kp2 = kpHelper.genKeyPair
    
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
    val k1 = prvAlice.keyAgreement(pubBob)
    val k2 = prvBob.keyAgreement(pubAlice)
    
    val k1Hex = k1.encode
    val k2Hex = k2.encode
    
    println("")
    println('''  Secret Key («k1.length» bytes): «k1Hex»''')
    println("  Key Agreement OK => " + (k1Hex == k2Hex))
    
    Assert.assertEquals(k1Hex, k2Hex)
  }
  
  @Test
  def void testECDSA() {
    val kpHelper = new KeyPairHelper
    val kp1 = kpHelper.genKeyPair
    val kp2 = kpHelper.genKeyPair
    
    val prvAlice = kp1.private
    val pubAlice = kp1.public
    val plaintext = "Signed text for Alice...".getBytes("UTF-8")
    
    println("Alice")
    println("  PlainText: " + new String(plaintext, "UTF-8"))
    println("  Private: " + prvAlice.keyToBytes.encode)
    println("  Public: " + pubAlice.keyToBytes.encode)
    
    println("")
    val signHelper = new SignatureHelper()
    val sig = signHelper.sign(prvAlice, plaintext)
    println('''  Signature («sig.length» bytes): «sig.encode»''')
    
    val expectedTrue = signHelper.verifySignature(pubAlice, plaintext, sig)
    println("  Signature OK => " + expectedTrue)
    Assert.assertTrue(expectedTrue)
    
    val expectedFalse = signHelper.verifySignature(kp2.public, plaintext, sig)
    println("  Signature OK => " + expectedFalse)
    Assert.assertFalse(expectedFalse)
  }
  
  @Test
  def void testAES() {
    val sKey = Arrays.copyOfRange("h4LjajPTHlLlls+eJC4SEYyFGbhInpnz2VMtS6MRXMLCvQAZK3no6nbv6bjVc4L2".decode, 0, 16)
    val cipherHelper = new CipherHelper(sKey)
    
    val plaintext = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    val iv = cipherHelper.randomBytes(16)
    
    val encrypted = cipherHelper.encrypt(iv, plaintext)
    println('''Encrypt: «plaintext» -> «encrypted.encode»''')
    
    val decrypted = cipherHelper.decrypt(iv, encrypted)
    println('''Decrypt: «encrypted.encode» -> «decrypted»''')
    
    Assert.assertEquals(plaintext, decrypted)
  }
}