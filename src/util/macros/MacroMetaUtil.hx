package util.macros;

/**
 * Helper functions for manipulating class and function metadata
 * inside macros.
 */

import haxe.macro.Expr;
import haxe.macro.Type;

class MacroMetaUtil
{
	/**
     * Given a class or field metadata definition
     * returns true if @rpc is present.
     */
	public static function isMetaRpcValue(meta :haxe.macro.Type.MetaAccess, metaname :String) :Bool
	{
		for (metaBlob in meta.get()) {
			if (metaBlob.name == metaname) {
				return true;
			}
		}
		return false;
	}

	/**
     * Given a class or field metadata definition
     * checks if @val is present and returns the string value
     * in @val(value)
     */
    public static function getMetaRpcStringValue(meta :haxe.macro.Type.MetaAccess, metaname :String) :String
	{
		var rpcValue :String = null;
		for (metaBlob in meta.get()) {
			if (metaBlob.name == metaname) {
				if (metaBlob.params != null) {
					for (param in metaBlob.params) {
						switch(param.expr) {
							default:
							case EConst(c):
								switch(c) {
									default:
									case CString(s):
										rpcValue = s;
								}
						}
					}
				}
				continue;//Stop looking
			}
		}

		return rpcValue;
	}
}
