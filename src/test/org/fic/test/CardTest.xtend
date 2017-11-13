package org.fic.test

import java.time.LocalDate
import java.time.Month
import java.time.format.DateTimeFormatter
import org.fic.api.CardBlock
import org.fic.api.TrustedLink
import org.fic.crypto.KeyPairHelper
import org.junit.Test

import static extension org.fic.crypto.Base64Helper.*
import org.junit.Assert

class CardTest {
  
  @Test
  def void testCardBlock() {
    val alexKp = new KeyPairHelper().genKeyPair
    val newCard = new CardBlock(alexKp.public) => [
      info.put("birthday", LocalDate.of(1981, Month.JANUARY, 28).format(DateTimeFormatter.ISO_LOCAL_DATE))
      links.add(new TrustedLink("url.pt", "pub-key-data"))
      sign(alexKp.private)
    ]
    
    println('''Alex newCard: «newCard.toJson»''')
    val cData = newCard.retrieve
    
    println('''  Encoded newCard: «cData.array.encode»''')
    val loadedCard = CardBlock.load(cData)
    
    println('''Alex loadedCard: «loadedCard.toJson»''')
    
    Assert.assertEquals(newCard.toJson, loadedCard.toJson)
  }
}