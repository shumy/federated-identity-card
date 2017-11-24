package org.fic.broker

enum NodeType { FIC, TL, APP } //FI-Card, Trusted-Link, Application

interface IBroker {
  def IChannel connect(NodeType nType, String uuid, String key)
}