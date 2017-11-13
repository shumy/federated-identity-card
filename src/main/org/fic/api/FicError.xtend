package org.fic.api

class FicError extends RuntimeException {
  val Class<?> clazz
  val int code
  
  new(Class<?> clazz, String msg, int code) {
    super(msg)
    
    this.clazz = clazz
    this.code = code
  }
}