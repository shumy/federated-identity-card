package org.fic.broker.msg.reply

import org.fic.broker.msg.FMessage

class RplAck extends FMessage {
  //reply with success:
  public static val OK = 0                          //OK ack
  
  //generic reply error codes:
  public static val UNKNOWN = -1                    //e.g for internal server errors
  public static val TIMEOUT = -2                    //for request timeouts
  public static val SIGNATURE = -3                  //e.g reply with an invalid signature
  
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
      
      case CHA_INACTIVE_CARD: "Inactive card-block."
      case CHA_NO_SYNC: "Out of sync, needs to evolve."
      
      case SUB_NO_ACTIVE_CARD: "No active card-chain found."
      
      case REG_EXISTENT_CARD: "Already existent card-block in the card-chain."
      case REG_CAND_NOT_ACCEPTED: "Candidate not accepted, the card-block is in the active state."
      
      case CR_NOT_FOUND: "No card-block or t-link found."
      
      case SCH_INVALID_QUERY: "Invalid query format: " + completeError
    }
    
    body.put("code", code)
    if (error !== null)
      body.put("error", error)
  }
  
  def getCode() { body.get("code") as Integer }
  def getError() { body.get("error") as String }
}