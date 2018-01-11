package org.fic.api

import org.eclipse.xtend.lib.annotations.Accessors
import org.bouncycastle.jce.provider.BouncyCastleProvider
import java.security.Security

class CryptoContext {
  
  @Accessors
  static class Context {
    public val String curveName
    public  val String signName
  }
  
  static val defaultContext = new Context("secp384r1", "SHA3-256withECDSA")
  
  static val context = new ThreadLocal<Context> {
    override protected initialValue() {
      Security.addProvider(new BouncyCastleProvider)
      defaultContext
    }
  }
  
  static def getCtx() { return context.get }
}