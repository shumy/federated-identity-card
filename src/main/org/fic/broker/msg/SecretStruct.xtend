package org.fic.broker.msg

import java.util.Map
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class SecretStruct {
  public static val ECDH_AES_CBC = "ecdh-aes-cbc" // { suite: "ecdh-aes-cbc", pk: <public-key>, curve: <curve> }
  
  public val Map<String, String> mode
  public val String nonce
}