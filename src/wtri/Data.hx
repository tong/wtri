package wtri;

@:forward
@:forwardStatics
abstract Data(Bytes) from Bytes to Bytes {

    inline function new( b : Bytes ) this = b;

    @:to public inline function toString()
        return this.toString();
    
    @:from public static inline function ofString( s : String ) : Data
        return Bytes.ofString(s);

}
