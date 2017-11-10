package org.fic.crypto

import java.security.PrivateKey
import java.security.PublicKey
import javax.crypto.KeyAgreement

class DiffieHellmanHelper {
  static def keyAgreement(PrivateKey prvKey, PublicKey pubKey) {
    val ka = KeyAgreement.getInstance("ECDH", "BC")
    ka.init(prvKey)
    ka.doPhase(pubKey, true)
    
    return ka.generateSecret
  }
}