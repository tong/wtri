package wtri.handler;

import sys.thread.Thread;
import wtri.net.WebSocket;

class WebSocketHandler implements wtri.Handler {

    public var clients(default,null) = new Array<Client>();

    public var onconnect : Client->Void;

    public function new( ?onconnect : Client->Void ) {
        this.onconnect = onconnect;
    }

    public inline function iterator() : Iterator<Client>
        return clients.iterator();

    public function handle( req : Request, res : Response ) : Bool {

        if( req.headers.get( Connection ) != 'Upgrade' &&
            req.headers.get( Upgrade ) != 'websocket' )
            return false;
        final skey = req.headers.get( Sec_WebSocket_Key );
        if( skey == null )
            return false;
        //var sversion = req.headers.get('Sec-WebSocket-Version');
        final key = WebSocket.createKey( skey );
        
        res.code = SWITCHING_PROTOCOL;
        res.headers.set( Connection, 'Upgrade' );
        res.headers.set( Upgrade, 'websocket' );
        res.headers.set( Sec_WebSocket_Accept, key );
        res.end();

        var client = new Client( this, cast(res.socket, TCPSocket).socket );
        clients.push( client );
        client.read();
        onconnect( client );
        //client.write('Welcome!');

        return true;
    }

    public function broadcast( data : Data ) {
        for( c in clients ) c.write( data );
    }
}

private class Client {

    public dynamic function onmessage( message : Bytes ) {}
    public dynamic function ondisconnect() {}

    public final handler : WebSocketHandler;
    public final socket : sys.net.Socket;

    var thread : Thread;

    public function new( handler : WebSocketHandler, socket : sys.net.Socket  ) {
        this.handler = handler;
        this.socket = socket;
    }

    public function read() {
        thread = Thread.create( () -> {
            //var main : Thread = Thread.readMessage( true );
            var sock : sys.net.Socket = Thread.readMessage( true );
            var _onmessage : Bytes->Void = Thread.readMessage( true );
            var _ondisconnect : Void->Void = Thread.readMessage( true );
            var frame : Bytes = null;
            while( true ) {
                try {
                    frame = WebSocket.readFrame( sock.input );
                } catch(e:haxe.io.Eof) {
                    trace(e);
                    _ondisconnect();
                    break;
                } catch(e) {
                    trace(e);
                    _ondisconnect();
                    break;
                }
                if( frame != null ) _onmessage( frame );
            }
        });
        //thread.sendMessage( Thread.current() );
        thread.sendMessage( socket );
        thread.sendMessage( s -> {
            onmessage(s);
        } );
        thread.sendMessage( () -> {
            close();
        } );
    }

    public inline function write( data : Data ) {
        WebSocket.writeFrame( socket.output, data );
    }

    public function close() {
        handler.clients.remove( this );
        try socket.close() catch(e) {
            trace(e);
        }
        ondisconnect();
    }
}
