package org.fic.broker

import org.fic.broker.msg.FMessage

interface IContext {
  def String getFrom() //uuid of the node trying to chat
  
  def FMessage getMessage()
  def void reply(FMessage reply)
}