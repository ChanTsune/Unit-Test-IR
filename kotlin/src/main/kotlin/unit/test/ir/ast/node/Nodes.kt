data class File(val body:List<Node>):Node{
package unit.test.ir.ast.node
}

data class FunctionDef(val name:String,val args:List<ArgumentDef>,val body:List<Node>):Node{
}

data class ClassDef(val name:String,val bases:List<String>,val fields:List<Name>,val body:List<FunctionDef>):Node{
}

data class Return(val value:Node):Node{
}

data class Assign(val target:Node,val value:Node):Node{
}

data class For(val value:Node,val generator:Node,val body:List<Node>):Node{
}

data class Block(val body:List<Node>):Node{
}

data class Try(val body:List<Node>):Node{
}

data class Raise(val value:Node):Node{
}

data class Catch(val body:List<Node>):Node{
}

data class BoolOp(val kind:String,val left:Node,val right:Node):Node{
}

data class BinOp(val kind:String,val left:Node,val right:Node):Node{
}

data class UnaryOp(val kind:String,val value:Node):Node{
}

data class Constant(val kind:String,val value:String):Node{
}

data class Attribute(val value:Node,val attribute:String):Node{
}

data class Subscript(val value:Node,val index:Node):Node{
}

data class Name(val name:String,val kind:String?):Node{
}

data class Array(val values:List<Node>):Node{
}

data class Tuple(val values:List<Node>):Node{
}

data class Call(val value:Node,val args:List<Node>,val kwArgs:List<KwArg>):Node{
}

data class ArgumentDef(val key:String,val default:Node?):Node{
}

data class KwArg(val key:String,val value:Node):Node{
}
