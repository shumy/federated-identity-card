package org.fic.api

import java.util.Collections
import java.util.HashMap
import java.util.LinkedList
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import java.util.List

@FinalFieldsConstructor
class ChainLink {
  @Accessors(PUBLIC_GETTER) package var boolean active = false
  @Accessors package val CardBlock card
  
  package val List<CRLink> crLinks// = new LinkedList<CRLink>
  def getLinks() { Collections.unmodifiableList(crLinks) }
}

@FinalFieldsConstructor
class CardChain {
  @Accessors val String uuid
  @Accessors val List<ChainLink> chain
  
  val candidates = new HashMap<String, CardBlock> //recover candidates
  
  var ChainLink current = null
  
  def isActive() { current.active }
  def getCard() { current.card }
  
  // create a card-chain with the registration card
  new(CardBlock regCard) {
    if (!regCard.signed)
      throw new FicError(CardChain, "The card chain only accepts signed cards!", 1)
    
    if (regCard.uuid != regCard.key)
      throw new FicError(CardChain, "The registration card must have the uuid == key!", 2)
    
    val head = new ChainLink(regCard, new LinkedList<CRLink>)
    
    uuid = regCard.key
    chain = new LinkedList<ChainLink>
    chain.add(head)
    
    current = head
    current.active = true
  }
  
  // create a card-chain with the chain-links
  new(List<ChainLink> chainLinks) {
    if (chainLinks.length === 0)
      throw new FicError(CardChain, "The chain-links is empty!", -1)
    
    val head = chainLinks.head
    val regCard = head.card
    
    if (regCard.uuid != regCard.key)
      throw new FicError(CardChain, "The registration card must have the uuid == key!", 2)
    
    uuid = regCard.key
    chain = chainLinks
    
    current = chainLinks.last
    current.active = true
  }
  
  // the candidate should be added only when accepted by Trusted Links?
  // depends on the protocol result
  def void addCandidate(CardBlock newCard) {
    if (!newCard.signed)
      throw new FicError(CardChain, "The card chain only accepts signed cards!", 3)
    
    if (newCard.uuid != uuid)
      throw new FicError(CardChain, "The card doesn't belong to the card chain!", 4)
    
    candidates.put(newCard.key, newCard)
  }
  
  def void addLink(CRLink crLink) {
    if (!crLink.signed)
      throw new FicError(CardChain, "The card chain only accepts signed links!", 5)
    
    if (crLink.uuid != uuid)
      throw new FicError(CardChain, "The cr-link doesn't belong to the card chain!", 6)
    
    if (crLink.prev != current.card.key)
      throw new FicError(CardChain, "The cr-link doesn't refer to the current card!", 7)
    
    //discard already available cr-links
    for (link : current.crLinks)
      if (link.key == crLink.key && link.type === crLink.type) return;
    
    //only valid cr-links are accepted. No need to verify in tryEvolve
    var isValidLink = false
    for (tl : current.card.links)
      if (isValidLink(tl.key, crLink.key))
        isValidLink = true
    
    if (!isValidLink)
      throw new FicError(CardChain, "The cr-link is not valid!", 8)
    
    
    //verify if it's a valid recover link (must have an recover candidate)
    if (crLink.type.bitwiseAnd(CRLink.RECOVER) == CRLink.RECOVER) {
      var isValidRecoverLink = false
      for (can : candidates.values)
        if (crLink.next == can.key)
          isValidRecoverLink = true
      
      if (!isValidRecoverLink)
        throw new FicError(CardChain, "The recover-link is not valid!", 9)
    }
    
    
    current.crLinks.add(crLink)
    tryEvolve
  }
  
  //merge with chain from another source, this must be already validated with a source signature
  def void merge(List<ChainLink> links) {
    
  }
  
  //verify the chain to calculate the current ChainLink and is state!
  private def void tryEvolve() {
    if (current.active) tryCancel
    if (!current.active) tryRecover
  }
  
  private def void tryCancel() {
    //TODO: the algorithm depends on the trusted link options
    
    //cancel if all trusted links have cancel responses
    var counter = 0
    for (tl : current.card.links)
      for (crLink : current.crLinks)
        if (crLink.type.bitwiseAnd(CRLink.CANCEL) === CRLink.CANCEL)
          counter++
    
    if (counter === current.card.links.length)
      current.active = false
  }
  
  private def void tryRecover() {
    //TODO: the algorithm depends on the trusted link options
    
    //recover if all trusted links have recover responses
    val candidateCounters = new HashMap<String, Integer>
    for (tl : current.card.links)
      for (crLink : current.crLinks)
        if (crLink.type.bitwiseAnd(CRLink.RECOVER) === CRLink.RECOVER) {
          var counter = candidateCounters.get(crLink.next) ?: 0
          counter++
          
          candidateCounters.put(crLink.next, counter)
        }
    
    // accept the firts candidate
    for (candidate : candidateCounters.entrySet)
      if (candidateCounters.get(candidate) === current.card.links.length) {
        //all good, evolve by recovering
        val nextLink = new ChainLink(candidates.get(candidate), new LinkedList<CRLink>)
        chain.add(nextLink)
        
        current = nextLink
        current.active = true
        
        //no need for these candidates anymore
        candidates.clear
      }
  }
  
  private def isValidLink(String trustedKey, String crLinkKey) {
    //TODO: validation can be more complex than a simple equality, depends if the trusted chain can also evolve
    trustedKey === crLinkKey
  }
}