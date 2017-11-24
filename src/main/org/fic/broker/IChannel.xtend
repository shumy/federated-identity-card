package org.fic.broker

import org.fic.broker.msg.FMessage

interface IChannel {
  //gateway uuid
  def String getGateway()
  
  //request/reply model
  def void send(FMessage msg) //send a message to the gateway, not expecting a reply
  def void send(FMessage msg, (FMessage)=>void onReply) //send a message to the gateway
  
  def void send(String to, FMessage msg) //send a message to the target node uuid, not expecting a reply
  def void send(String to, FMessage msg, (FMessage)=>void onReply) //send a message to the target node uuid
  
  def void onReceive((IContext)=>void onMessage) //some other node is trying to chat
  
  //local connection management
  def void disconnect() //explicit disconnect from the gateway, this will not call onDisconnect
  def void onDisconnect(Throwable ex) //when the connection was forcibly closed
}