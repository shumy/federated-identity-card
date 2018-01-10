package org.fic.broker

interface IBroker {
  def IChannel connect(String url,  String uuid)
}