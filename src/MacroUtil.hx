import Type in StdType;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.ComplexTypeTools;
import haxe.macro.TypeTools;

import haxe.DynamicAccess;

class MacroUtil
{
	/**
	 * Given a class expression, returns the class name
	 * @param  classNameExpr :Expr         Class<Dynamic>
	 * @return               String of the full class name
	 */
	public static function getClassNameFromClassExpr (classNameExpr :Expr) :String
	{
		var drillIntoEField = null;
		var className = "";
		drillIntoEField = function (e :Expr) :String {
			switch(e.expr) {
				case EField(e2, field):
					return drillIntoEField(e2) + "." + field;
				case EConst(c):
					switch(c) {
						case CIdent(s):
							return s;
						case CString(s):
							return s;
						default:Context.warning(StdType.enumConstructor(c) + " not handled", Context.currentPos());
							return "";
					}
				default: Context.warning(StdType.enumConstructor(e.expr) + " not handled", Context.currentPos());
					return "";
			}
		}
		switch(classNameExpr.expr) {
			case EField(e1, field):
				className = field;
				switch(e1.expr) {
					case EField(_, _):
						className = drillIntoEField(e1) + "." + className;
					case EConst(c):
						switch(c) {
							case CIdent(s):
								className = s + "." + className;
							case CString(s):
								className = s + "." + className;
							default:Context.warning(StdType.enumConstructor(c) + " not handled", Context.currentPos());
						}
					default: Context.warning(StdType.enumConstructor(e1.expr) + " not handled", Context.currentPos());
				}
			case EConst(c):
				switch(c) {
					case CIdent(s):
						className = s;
					case CString(s):
						className = s;
					default:Context.warning(StdType.enumConstructor(c) + " not handled", Context.currentPos());
				}
			default: Context.warning(StdType.enumConstructor(classNameExpr.expr) + " not handled", Context.currentPos());
		}

		return className;
	}

	/**
	 * Inserts an expression into the function block, either at the beginning, or the end of the block.
	 */
	public static function insertExpressionIntoFunction(exprToAdd :Expr, func :Function, ?beginningOfFunction :Bool = true) :Void
	{
		if (Context.defined("display")) {
			// When running in code completion, skip out early
			return;
		}
		if (func.expr != null) {
			switch(func.expr.expr) {
				case EBlock(exprs): //exprs : Array<Expr>
					if (exprToAdd != null) {
						if (beginningOfFunction) {
							exprs.unshift(exprToAdd);
						} else {
							exprs.push(exprToAdd);
						}
					}
				default:
			}
		}
	}

	/**
	 * Searches superclass as well.
	 */
	public static function classContainsField(cls :ClassType, fieldName :String) :Bool
	{
		if (cls == null) {
			return false;
		}

		if (cls.fields != null) {
			for (field in cls.fields.get()) {
				if (field.name == fieldName) {
					return true;
				}
			}
		}

		return classContainsField(cls.superClass != null ? cls.superClass.t.get() : null, fieldName);
	}


	/**
	 * Searches superclass as well.
	 */
	public static function getAllClassFields(cls :ClassType) :Array<ClassField>
	{
		if (cls == null) {
			return null;
		}

		var fields = [];
		if (cls.fields.get() != null) {
			for (field in cls.fields.get()) {
				fields.push(field);
			}
		}

		if (cls.superClass == null) {
			return fields;
		} else {
			var superFields = getAllClassFields(cls.superClass.t.get());
			if (superFields == null) {
				return fields;
			} else {
				return fields.concat(superFields);
			}
		}
	}
}
