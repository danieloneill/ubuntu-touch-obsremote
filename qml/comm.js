var comm = {
    m_requestNumber: 1,
    m_requests: {},

    request: function( obj, cb )
    {
        obj['message-id'] = ""+this.m_requestNumber++;
        var pkt = JSON.stringify(obj,null,2);
        //console.log("Transmitting: "+pkt);
        webSocket.sendTextMessage(pkt);
        this.m_requests[ obj['message-id'] ] = { 'request':obj, 'callback':cb, 'whence':new Date() };
    },

    handlePacket: function(client, msg, packet)
    {
        if( msg['message-id'] )
        {
            // Use the msgid callback:
            var mid = msg['message-id'];
            var req = this.m_requests[mid];
            if( !req )
            {
                console.log(" *** UNHANDLED MESSAGE!");
                return;
            }

            req.callback( req.request, msg );
            delete this.m_requests[mid];
        }
        else
        {
            // broadcast, heartbeat:
            //console.log("Got heartbeat, maybe: "+packet);
            if( msg['update-type'] == 'Heartbeat' )
            {
                // Cool. Info.
                indStreaming.streaming = msg['streaming'];

                if( !streamingSwitch.knownState )
                {
                    streamingSwitch.checked = msg['streaming'];
                    streamingSwitch.knownState = true;
                }

                cpuUsage.text = ''+msg['stats']['cpu-usage'].toFixed(1);
            }
            else if( msg['update-type'] == 'StreamStatus' )
            {
                dropped.text = ''+msg['num-dropped-frames'];
                totalFrames.text = ''+msg['output-total-frames'];
                bitrate.text = msg['kbits-per-sec'];
                uptime.text = this.toUptime( msg['total-stream-time'] );
            }
        }

        return true;
    },

    requestScenesList: function()
    {
        var req = { 'request-type':'GetSceneList' };
        this.request( req, function(nreq, nres) {
            scenesModel.clear();
            for( var x=0; x < nres['scenes'].length; x++ )
            {
                var nent = nres['scenes'][x];
                scenesModel.append(nent);
                if( nent['name'] == nres['current-scene'] )
                    scenesList.currentIndex = x;
            }

            scenesList.enabled = true;
        } );
    },

    loggedIn: function()
    {
        this.requestScenesList();
    },

    toUptime: function(elapsed)
    {
        var outline = '';
        var secondsInADay = 60 * 60 * 1000 * 24,
            secondsInAHour = 60 * 60 * 1000;

        var days = Math.floor( elapsed / 86400 );
        if( days > 0 )
            elapsed -= ( days * 86400 );

        var hours = Math.floor( elapsed / 3600 );
        if( hours > 0 )
            elapsed -= ( hours * 3600 );

        var mins = Math.floor( elapsed / 60 );
        if( mins > 0 )
            elapsed -= ( mins * 60 );

        var secs = elapsed;

        var delim = '';
        if( days > 0 ) { outline += delim+days+'d'; delim = ' '; }
        if( hours > 0 ) { outline += delim+hours+'h'; delim = ' '; }
        if( mins > 0 ) { outline += delim+mins+'m'; delim = ' '; }
        if( secs > 0 ) { outline += delim+secs+'s'; delim = ' '; }

        return outline;
    }
}
