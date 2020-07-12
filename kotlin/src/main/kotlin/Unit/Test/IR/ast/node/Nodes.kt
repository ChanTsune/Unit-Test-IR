package Unit.Test.IR.ast.node
data class File(val Body:List<Node>){
}

data class FunctionDef(val Name:String,val Args:List<ArgumentDef>,val Body:List<Node>){
}

data class ClassDef(val Name:String,val Bases:List<String>,val Fields:List<Name>,val Body:List<FunctionDef>){
}

data class Return(val Value:Node){
}

data class Assign(val Target:Node,val Value:Node){
}

data class For(val Value:Node,val Generator:Node,val Body:List<Node>){
}

data class Block(val Body:List<Node>){
}

data class Try(val Body:List<Node>){
}

data class Raise(val Value:Node){
}

data class Catch(val Body:List<Node>){
}

data class BoolOp(val Kind:String,val Left:Node,val Right:Node){
}

data class BinOp(val Kind:String,val Left:Node,val Right:Node){
}

data class UnaryOp(val Kind:String,val Value:Node){
}

data class Constant(val Kind:String,val Value:String){
}

data class Attribute(val Value:Node,val Attribute:String){
}

data class Subscript(val Value:Node,val Index:Node){
}

data class Name(val Name:String,val Kind:String?){
}

data class Array(val Values:List<Node>){
}

data class Tuple(val Values:List<Node>){
}

data class Call(val Value:Node,val Args:List<Node>,val KwArgs:List<KwArg>){
}

data class ArgumentDef(val Key:String,val Default:Node?){
}

data class KwArg(val Key:String,val Value:Node){
}
