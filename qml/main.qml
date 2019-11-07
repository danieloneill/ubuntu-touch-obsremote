import QtQuick 2.7
//import QtQuick.Controls 1.3
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3

import QtWebSockets 1.0
import Qt.labs.settings 1.0

import Crypto 1.0

import 'comm.js' as JS

MainView {
    id: main
    applicationName: 'OBSRemote'
    automaticOrientation: true
    width: units.gu(45)
    height: units.gu(75)
    visible: true

    Settings {
        id: settings
        property string host: 'ws://192.168.7.36:4444'
        property string password
    }

    PageStack {
        id: pageStack
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: statusBar.top
        }

        Page {
            id: pageSetup
            PageHeader {
                title: qsTr('OBS Remote')
                id: header
            }

            GridLayout {
                id: settingsBox
                anchors {
                    left: parent.left
                    top: header.bottom
                    right: parent.right
                    margins: 10
                }

                columns: 2
                columnSpacing: 5
                rowSpacing: 10

                Label { text: 'Host:'; visible: !indConnected.connected }
                TextField {
                    onTextChanged: settings.host = text;
                    text: settings.host
                    placeholderText: "ws://192.168.0.10:4444/"
                    Layout.fillWidth: true
                    visible: !indConnected.connected
                }
                Label { text: 'Password:'; visible: !indConnected.connected }
                TextField {
                    onTextChanged: settings.password = text;
                    text: settings.password
                    echoMode: TextInput.PasswordEchoOnEdit
                    Layout.fillWidth: true
                    visible: !indConnected.connected
                }

                RowLayout {
                    Layout.columnSpan: 2

                    Item {
                        height: 1
                        width: 1
                        Layout.fillWidth: true
                    }

                    Column {
                        Label {
                            text: qsTr('Active')
                        }
                        Switch {
                            onCheckedChanged: webSocket.active = checked;
                        }
                    }

                    Item {
                        height: 1
                        width: 1
                        Layout.fillWidth: true
                    }

                    Column {
                        Label {
                            text: qsTr('Stream')
                        }
                        Switch {
                            id: streamingSwitch
                            property bool knownState: false

                            onCheckedChanged: {
                                if( !knownState )
                                    return;

                                streamingSwitch.enabled = false;
                                var pkt;
                                if( streamingSwitch.checked )
                                    pkt = { 'request-type':'StartStreaming' };
                                else
                                    pkt = { 'request-type':'StopStreaming' };

                                JS.comm.request( pkt, function(req, res) {
                                    streamingSwitch.enabled = true;
                                });
                            }
                        }
                    }

                    Item {
                        height: 1
                        width: 1
                        Layout.fillWidth: true
                    }
                } // RowLayout
            }

            UbuntuListView {
                id: scenesList
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    top: settingsBox.bottom
                    margins: 5
                }

                header: PageHeader { title: 'Scenes' }

                delegate: ListItem {
                    ListItemLayout {
                        title.text: scenesModel.get(index)['name']
                    }
                    onClicked: {
                        var newName = scenesModel.get(index)['name'];
                        //console.log("Wants "+newName);
                        if( index == scenesList.currentIndex )
                            return; // no-op

                        scenesList.enabled = false;
                        var pkt = { 'request-type':'SetCurrentScene', 'scene-name':newName };
                        JS.comm.request( pkt, function(req, res) {
                            JS.comm.requestScenesList();
                        });
                    }
                }
                model: ListModel { id: scenesModel }
            }
        } // Page
    } // PageStack

    GridLayout {
        id: statusBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 5
        }
        columns: 3

        Row {
            Rectangle {
                id: indConnected
                property bool connected: false
                radius: 90
                width: 16
                height: 16
                color: connected ? 'green' : 'gray'
            }

            Label {
                color: indConnected.color
                text: ' Connected'
            }
        }

        Rectangle { width: parent.width * 0.25; height: 5; color: 'transparent'; visible: false == indConnected.connected }
        Row {
            visible: indConnected.connected
            Label { text: 'CPU: ' }
            Label { id: cpuUsage }
            Layout.alignment: Text.AlignHCenter
        }

        Rectangle { width: parent.width * 0.25; height: 5; color: 'transparent'; visible: false == indStreaming.streaming }
        Row {
            visible: indStreaming.streaming
            Layout.alignment: Text.AlignRight
            Label { id: dropped }
            Label { text: '/' }
            Label { id: totalFrames }
            Label { text: ' dropped' }
        }

        Row {
            Rectangle {
                id: indStreaming
                property bool streaming: false
                radius: 90
                width: 16
                height: 16
                color: streaming ? 'green' : 'gray'
            }

            Label {
                text: ' Streaming'
                color: indStreaming.color
            }
        }

        Rectangle { width: parent.width * 0.25; height: 5; color: 'transparent'; visible: false == indStreaming.streaming }
        Row {
            visible: indStreaming.streaming
            Layout.alignment: Text.AlignHCenter
            Label { id: bitrate }
            Label { text: 'kbps' }
        }

        Rectangle { width: parent.width * 0.25; height: 5; color: 'transparent'; visible: false == indStreaming.streaming }
        Row {
            visible: indStreaming.streaming
            Layout.alignment: Text.AlignRight
            Label { id: uptime }
        }
    }

    Crypto {
        id: hash
    }

    WebSocket {
        id: webSocket
        url: settings.host
        //active: true

        onStatusChanged: {
            if( webSocket.status == WebSocket.Connecting )
                console.log("Connecting to "+webSocket.url+"...");
            else if( webSocket.status == WebSocket.Closing )
                console.log("Disconnecting from "+webSocket.url+"...");
            else if( webSocket.status == WebSocket.Closed )
            {
                console.log("Disconnected from "+webSocket.url+".");
                //webSocket.active = false;
                //webSocket.active = true;
                indConnected.connected = false;
            }
            else if( webSocket.status == WebSocket.Error )
                console.log("Error: "+webSocket.errorString);
            else if( webSocket.status == WebSocket.Open )
            {
                console.log("Connected.");
                streamingSwitch.knownState = false;

                var pkt = { "request-type":"GetAuthRequired" };
                JS.comm.request( pkt, function(request, response) {
                    //console.log("Got response: "+JSON.stringify(response,null,2));

                    // If auth is required, let's do it:
                    if( response['authRequired'] )
                    {
                        var password = settings.password;
                        var challenge = response['challenge'];
                        var salt = response['salt'];

                        var secret_hash = hash.toBase64( hash.sha256(password+salt, true) );
                        var auth_response_hash = hash.sha256(secret_hash + challenge, true);
                        var auth_response = ""+hash.toBase64(auth_response_hash);

                        var npkt = {"request-type":"Authenticate","auth":''+auth_response};
                        JS.comm.request( npkt, function(nrequest,nresponse) {
                            //console.log("Login response: "+JSON.stringify(nresponse,null,2));
                            if( nresponse['status'] == 'ok' )
                            {
                                indConnected.connected = true;
                                JS.comm.loggedIn();
                            }
                        } );
                    }
                    else
                    {
                        indConnected.connected = true;
                        JS.comm.loggedIn();
                    }
                } );
            }
        }
        onTextMessageReceived: {
            var part = JSON.parse(message);
            JS.comm.handlePacket(null, part, message);
        }
    }
}
