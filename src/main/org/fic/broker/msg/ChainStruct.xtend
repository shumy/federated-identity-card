package org.fic.broker.msg

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class ChainStruct {
  public val String block     //encoded CardBlock
  public val String[] links   //encoded CRLink's
}