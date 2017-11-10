package org.fic

import java.security.Security
import java.time.LocalDate
import java.time.Month
import java.time.format.DateTimeFormatter
import java.util.Arrays
import org.bouncycastle.jce.provider.BouncyCastleProvider
import org.fic.api.CardBlock
import org.fic.crypto.CipherHelper
import org.fic.crypto.KeyPairHelper
import org.fic.crypto.SignatureHelper

import static extension org.fic.crypto.Base64Helper.*
import static extension org.fic.crypto.DiffieHellmanHelper.*
import static extension org.fic.crypto.KeyLoaderHelper.*

//import static extension org.fic.EllipticCurveHelper.*

class MainTest {
  def static void main(String[] args) {
    Security.addProvider(new BouncyCastleProvider)
    
    println("----testECDSA----")
    testECDSA
    
    println("\n----testECDH----")
    val key = testECDH
    
    println("\n----testAES----")
    testAES(key)
    
    println("\n----testCardBlock----")
    testCardBlock
  }
  
  def static testCardBlock() {
    val alexKp = new KeyPairHelper().genKeyPair
    val newCard = new CardBlock("Alex Name", alexKp.public) => [
      info.put("birthday", LocalDate.of(1981, Month.JANUARY, 28).format(DateTimeFormatter.ISO_LOCAL_DATE))
      sign(alexKp.private)
    ]
    
    println('''Alex newCard: «newCard.toJson»''')
    val cData = newCard.retrieve
    
    println('''  Encoded newCard: «cData.array.encode»''')
    val loadedCard = CardBlock.load(cData)
    
    println('''Alex loadedCard: «loadedCard.toJson»''')
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
    
    return k1
  }
  
  def static testECDSA() {
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
    
    val expectedFalse = signHelper.verifySignature(kp2.public, plaintext, sig)
    println("  Signature OK => " + expectedFalse)
  }
}