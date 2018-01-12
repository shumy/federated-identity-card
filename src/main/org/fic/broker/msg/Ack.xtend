package org.fic.broker.msg

import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.broker.msg.FMessage

class Ack extends FMessage {
  //reply with success:
  public static val OK = 0                                  //OK ack
  
  //generic reply error codes:
  public static val UNKNOWN = -1                            //e.g for internal server errors
  public static val TIMEOUT = -2                            //for request timeouts
  public static val SIGNATURE = -3                          //e.g reply with an invalid signature
  
  public static val NO_CHAIN = -4                           //non existent card-chain
  public static val CHAIN_ACTIVE = -5                       //card-chain active when inactive chain is required
  public static val CHAIN_INACTIVE = -6                     //card-chain inactive when active chain is required
  
  //Challenge errors:
  public static val CHA_NO_SYNC = 1                         //out of sync, needs to evolve
  public static val CHA_UNSUPPORTED = 2                     //encryption mode not supported
  
  //Register errors:
  public static val REG_EXISTENT_CARD = 201                 //already existent card in the card-chain
  
  //Cancel/Recover errors:
  public static val CR_NOT_FOUND = 301                      //no card-block or t-link found.
  
  //Search errors:
  public static val SCH_INVALID_QUERY = 401                 //invalid query
  
  protected new() { /* used for JSON load only */ }
  new(String from, String to, Integer code) { this(from, to, code, null) }
  new(String from, String to, Integer code, String completeError) {
    super(null, ACK, from, to)
    
    val error = switch(code) {
      case OK: null
      case UNKNOWN: "Unknown error!"
      case TIMEOUT: "Timeout error!"
      case SIGNATURE: "Signature error!"
      
      case NO_CHAIN: "Non existent card-chain!"
      case CHAIN_ACTIVE: "CardChain is active, when inactive state is required!"
      case CHAIN_INACTIVE: "CardChain is inactive, when active state is required!"
      
      case CHA_NO_SYNC: "Out of sync, needs to evolve."
      case CHA_UNSUPPORTED: "Unsupported encryption mode."
      
      case REG_EXISTENT_CARD: "Already existent card-block in the card-chain."
      
      case CR_NOT_FOUND: "No card-block or t-link found."
      
      case SCH_INVALID_QUERY: "Invalid query format: " + completeError
    }
    
    this.body = new Body(code, error)
  }
  
  @Accessors(PUBLIC_GETTER) var Body body
  
  @JsonInclude(Include.NON_NULL)
  static class Body {
    protected new() { /* used for JSON load only */ }
    new(Integer code, String error) {
      this.code = code
      this.error = error
    }
    
    @Accessors(PUBLIC_GETTER) var Integer code
    @Accessors(PUBLIC_GETTER) var String error
  }
}