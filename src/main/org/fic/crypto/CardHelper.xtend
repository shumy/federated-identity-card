package org.fic.crypto

import java.security.PrivateKey
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.fic.api.CardBlock
import org.fic.api.TrustedLink

@FinalFieldsConstructor
class CardInfo {
  public val PrivateKey prvKey
  public val CardBlock block
}

class CardHelper {
  static def CardInfo create(Map<String, String> cardInfo) {
    return create(null, cardInfo, #[])
  }
  
  static def CardInfo create(Map<String, String> cardInfo, List<TrustedLink> cardlLinks) {
    return create(null, cardInfo, cardlLinks)
  }
  
  static def CardInfo create(String uuid, Map<String, String> cardInfo) {
    return create(uuid, cardInfo, #[])
  }
  
  static def CardInfo create(String uuid, Map<String, String> cardInfo, List<TrustedLink> cardlLinks) {
    val keyPair = new KeyPairHelper().genKeyPair
    val pk = keyPair.private
    
    val newCard = new CardBlock(keyPair.public, uuid) => [
      info.putAll(cardInfo)
      links.addAll(cardlLinks)
      sign(pk)
    ]
    
    return new CardInfo(pk, newCard)
  }
}