package org.fic.crypto

import com.google.common.io.BaseEncoding

class Base64Helper {
  val static b64Codec = BaseEncoding.base64
  
  def static encode(byte[] bytes) {
    b64Codec.encode(bytes)
  }
  
  def static decode(String data) {
    b64Codec.decode(data)
  }
}