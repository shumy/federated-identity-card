package org.fic.api

import org.eclipse.xtend.lib.annotations.Accessors
import org.bouncycastle.jce.provider.BouncyCastleProvider
import java.security.Security

class CryptoContext {
  
  @Accessors
  static class Context {
    String curveName
    String signName
  }
  
  static val defaultContext = new Context => [
    curveName = "secp384r1"
    signName = "SHA3-256withECDSA"
  ]
  
  static val context = new ThreadLocal<Context> {
    override protected initialValue() {
      Security.addProvider(new BouncyCastleProvider)
      defaultContext
    }
  }
  
  static def getCtx() { return context.get }
}