package org.fic.api

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.annotation.JsonProperty
import java.nio.ByteBuffer
import java.security.PublicKey
import java.util.HashMap
import java.util.HashSet
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtend.lib.annotations.Data

@Data
class Link {
  public val String uuid
  public val String key
  
  @JsonCreator
  new(@JsonProperty("uuid") String uuid, @JsonProperty("key") String key) {
    this.uuid = uuid
    this.key = key
  }
}

class RRLink extends SignedBlock {
  enum Type { REVOKE, RECOVER }
  
  @Accessors(PUBLIC_GETTER) var Type type
  @Accessors(PUBLIC_GETTER) var Link reg  // reference to the registration card (confirming that the RRLink is for the CardChain)
  @Accessors(PUBLIC_GETTER) var Link prev // reference to the revoked card
  @Accessors(PUBLIC_GETTER) var Link next = null // reference to the recovered card, non existent on revoke
  
  private new() { /* used for JSON load only */ }
  private new(PublicKey pubKey, String curveName, String signName) {
    super(pubKey, curveName, signName)
  }
  
  static def newRevoke(PublicKey pubKey, Link regLink, Link prevLink) {
    RRLink.newRevoke(pubKey, regLink, prevLink, "prime256v1", "SHA256withECDSA")
  }
  
  static def newRevoke(PublicKey pubKey, Link regLink, Link prevLink, String curveName, String signName) {
    return new RRLink(pubKey, curveName, signName) => [
      type = Type.REVOKE
      reg = regLink
      prev = prevLink
    ]
  }
  
  static def newRecover(PublicKey pubKey, Link regLink, Link prevLink, Link nextLink) {
    RRLink.newRecover(pubKey, regLink, prevLink, nextLink, "prime256v1", "SHA256withECDSA")
  }
  
  static def newRecover(PublicKey pubKey, Link regLink, Link prevLink, Link nextLink, String curveName, String signName) {
    return new RRLink(pubKey, curveName, signName) => [
      type = Type.RECOVER
      reg = regLink
      prev = prevLink
      next = nextLink
    ]
  }
  
  static def load(ByteBuffer data) { SignedBlock.load(RRLink, data) }
}

@FinalFieldsConstructor
class CardChain {
  //val chain = new LinkedList<CardBlock>
  val cards = new HashMap<String, CardBlock>
  val links = new HashMap<String, Set<RRLink>>
  
  var boolean active   // if the current card is active or revoked?
  var CardBlock card   // the current card...
  
  public val String uuid
  public val String key
  
  // create a card chain with the registration card
  new(CardBlock regCard) {
    uuid = regCard.uuid
    key = regCard.uuid
    
    active = true
    card = regCard
    regCard.addCard
  }
  
  def void addCard(CardBlock newCard) {
    if (!newCard.sealed)
      throw new RuntimeException("The card chain only accepts sealed cards!")
    
    cards.put(newCard.uuid, newCard)
    evolve
  }
  
  def void addLink(RRLink link) {
    if (!link.sealed)
      throw new RuntimeException("The card chain only accepts sealed links!")
    
    if (link.reg.uuid != uuid || link.reg.key != key)
      throw new RuntimeException("The link doesn't belong to the card chain!")
    
    var set = links.get(link.prev.uuid) 
    if (set === null) {
      set = new HashSet<RRLink>
      links.put(link.prev.uuid, set)
    }
    
    set.add(link)
    evolve
  }
  
  //TODO: merge with other valid chain
  
  // validate the complete chain, signatures of cards and links
  @JsonIgnore
  def isValid() {
    
  }
  
  private def CardBlock nextCard(CardBlock tCard) {
    //TODO: verify if all conditions are met to evolve onto the next card?
  }
  
  // verify the link/chain to calculate the current card!
  private def void evolve() {
    var current = card
    
    var CardBlock next = null
    while( (next = nextCard(current)) !== null )
      current = next
    
    //TODO: is the card active ?
  }
}