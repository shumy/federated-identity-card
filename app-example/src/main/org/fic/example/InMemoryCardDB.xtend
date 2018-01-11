package org.fic.example

import java.util.HashMap
import org.fic.api.CardBlock
import org.fic.api.CardChain

class InMemoryCardDB {
  val chains = new HashMap<String, CardChain>  // uuid - CardChain 
  
  def void newChain(CardBlock block) {
    if (chains.get(block.uuid) !== null)
      throw new RuntimeException("UUID already exists!")
    
    chains.put(block.uuid, new CardChain(block))
  }
  
  def void newCandidate(CardBlock block) {
    val chain = chains.get(block.uuid)
    
    
    //if (chains.get(block.uuid) !== null)
    //  throw new RuntimeException("UUID already exists!")
    
    //chains.put(block.uuid, new CardChain(block))
  }
}