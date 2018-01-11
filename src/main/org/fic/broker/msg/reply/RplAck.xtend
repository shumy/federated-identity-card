package org.fic.broker.msg.reply

import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include
import org.eclipse.xtend.lib.annotations.Accessors
import org.fic.broker.msg.FMessage

class RplAck extends FMessage {
  //reply with success:
  public static val OK = 0                          //OK ack
  
  //generic reply error codes:
  public static val UNKNOWN = -1                    //e.g for internal server errors
  public static val TIMEOUT = -2                    //for request timeouts
  public static val SIGNATURE = -3                  //e.g reply with an invalid signature
  public static val NO_CHAIN = -4                   //e.g non existent card-chain
  
  //Challenge errors:
  public static val CHA_INACTIVE_CARD = 1                   //when inactive CardBlock
  public static val CHA_NO_SYNC = 2                         //out of sync, needs to evolve
  
  //Subscribe errors:
  public static val SUB_NO_ACTIVE_CARD = 101                //when no active card-chain found
  
  //Register errors:
  public static val REG_EXISTENT_CARD = 201                 //already existent card in the card-chain
  public static val REG_CAND_NOT_ACCEPTED = 202             //candidate not accepted, the card-block is in the active state
  
  //Cancel/Recover errors:
  public static val CR_NOT_FOUND = 301                      //no card-block or t-link found.
  
  //Search errors:
  public static val SCH_INVALID_QUERY = 401                 //invalid query
  
  protected new() { /* used for JSON load only */ }
  new(String from, String to, Integer code) { this(from, to, code, null) }
  new(String from, String to, Integer code, String completeError) {
    super(REPLY, ACK, from, to)
    
    val error = switch(code) {
      case OK: null
      case UNKNOWN: "Unknown error!"
      case TIMEOUT: "Timeout error!"
      case SIGNATURE: "Signature error!"
      case NO_CHAIN: "Non existent card-chain!"
      
      case CHA_INACTIVE_CARD: "Inactive card-block."
      case CHA_NO_SYNC: "Out of sync, needs to evolve."
      
      case SUB_NO_ACTIVE_CARD: "No active card-chain found."
      
      case REG_EXISTENT_CARD: "Already existent card-block in the card-chain."
      case REG_CAND_NOT_ACCEPTED: "Candidate not accepted, the card-block is in the active state."
      
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