import QtQuick 2.7
import QtQuick.Controls 2.12
import QtQuick.Window 2.0
import QtMultimedia 5.12
import QtWebView 1.1
import Qt.labs.settings 1.1
import unik.UnikQProcess 1.0
import unik.Unik 1.0

ApplicationWindow{
    id: app
    visible: true
    visibility: "Maximized"
    color: 'transparent'
    title: 'Twicht Chat Speech'
    property int fs: width*0.02
    property string userAdmin: 'RicardoMartinPizarro'
    onClosing: {
        close.accepted = true
        Qt.quit()
    }
    onVisibilityChanged: {
        if(app.visibility===ApplicationWindow.Maximized){
            //app.editable=!app.editable
            //showMode(app.editable)
        }
    }
    Unik{id: unik}
    Audio {
        id: mpRing
        source: 'file:/home/ns/nsp/uda/twitch-chat/sounds/ring_1.mp3';
        autoLoad: true
        autoPlay: true
    }
    Audio {
        id: mp2
        //source: 'file:/home/ns/nsp/uda/twitch-chat/sounds/ring_1.mp3';
        //autoLoad: true
        //autoPlay: true
        onPlaybackStateChanged:{
            if(mp2.playbackState===Audio.StoppedState){
                playlist2.removeItem(0)
            }
        }
        playlist: Playlist {
            id: playlist2
            onItemCountChanged:{
                //xMsgList.actualizar(playlist)
            }
        }
    }
    Audio {
        id: mp;
        onPlaybackStateChanged:{
            if(mp.playbackState===Audio.StoppedState){
                playlist.removeItem(0)
            }
        }
        playlist: Playlist {
            id: playlist
            onItemCountChanged:{
                xMsgList.actualizar(playlist)
            }
        }
    }
    Settings{
        id: apps
        property string uHtml: ''
    }
    Item{
        id: xAppWV
        anchors.fill: parent
        //opacity: app.editable?1.0:0.65
        WebView{
            id: wv
            width: parent.width
            height: parent.height//*0.5
            x:app.width+1280
            //            y: 100
            //url:"https://streamlabs.com/widgets/chat-box/v1/15602D8555920F741CDF"
            url:"https://twitch.tv/ricardomartinpizarro/chat"

            //visible:false
            onLoadProgressChanged:{
                if(loadProgress===100){
                    tCheck.start()
                }
            }
        }
    }
    Item{
        id: xApp
        anchors.fill: parent
        //opacity: app.editable?1.0:0.65
        Rectangle{
            id: xLed
            width: 100
            height: width
            border.width: 4
            border.color: '#ff8833'
            radius: 10
            property bool toogle: false
            color: toogle?'red':'green'
            visible: false
            Text {
                id: info
                text: 'nada'
                font.pixelSize: 24
                width: xApp.width-20
                wrapMode: Text.WordWrap
                anchors.left: parent.left
                anchors.leftMargin: 20
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    Qt.quit()
                    app.editable=false
                    console.log('Desactivando...')
                    showMode(app.editable)
                }
                Rectangle{
                    anchors.fill: parent
                    color: '#ff8833'
                }
            }
        }


    }
    property string uMsg: 'null'
    Timer{
        id: tCheck
        running: true
        repeat: true
        interval: 1000
        property int v: 0
        property bool e: false
        onTriggered: {
            running=false
            wv.runJavaScript('function doc(){var d=document.body.innerHTML; return d;};doc();', function(html){
                //console.log('Doc: '+html)
                if(html&&html!==apps.uHtml){
                    if(html.indexOf(app.userAdmin)>=0 && html.indexOf('eqmlnot')>=0){
                        tCheck.e=true
                    }
                    if(html.indexOf(app.userAdmin)>=0 && html.indexOf('dqmlnot')>=0){
                        tCheck.e=false
                    }
                    if(html.indexOf(':')>=0 && e){
                        console.log('yes'+tCheck.v)

                        tCheck.v++
                        if(tCheck.v >=1){
                            let m0 = html.split('author__')//html.replace(/<[^>]+>/g, '');
                            //console.log('Html:'+html)
                            if(m0.length>0){
                                //console.log('Html:'+m0[m0.length-1])
                                let m1=m0[m0.length-1].split(';">')
                                if(m1.length>0){
                                    let m2=m1[1].split('<')
                                    //console.log('De:'+m2[0])
                                    let m3=m0[1].split('text">')
                                    //console.log('m2 1:'+m1[1])
                                    if(m3.length>0){
                                        let m4=m1[1].split('chat-message-text">')
                                        //console.log('m4[1]:'+m4[1])
                                        if(m4.length>0){
                                            let m5=m4[1].split('<')
                                            let de=m2[0]
                                            let msg=m5[0]
                                            console.log('De:'+de)
                                            console.log('Dice:'+msg)
                                            sendNot(de, msg)
                                        }
                                    }
                                }
                            }

                        }
                    }
                }else{
                    //unik.speak('NO')
                    //apps.uHtml=''
                    running=true
                    return
                }
                apps.uHtml=html
                running=true
            });
        }
    }



    Shortcut{
        sequence: 'Esc'
        onActivated: {
            for(var i=0;i<xAlarmVisual.children.length;i++){
                //xAlarmVisual.children[i].destroy()
            }
            xAlarmVisual.visible=false
        }
    }
    UnikQProcess{
        id: uqp
        onLogDataChanged: {
            console.log('LogData: '+logData)
        }
    }
    Component.onCompleted: {

    }
    function sendNot(from, msg){
        let d=new Date(Date.now())
        let sd=''+d.getDate()+'/'+parseInt(d.getMonth()+1)+'/'+d.getFullYear()
        let s='Nuevo mensaje en el chat de Twitch - '+sd+'De: '+from+' Mensaje: '+msg
        let cmd='sh '
        cmd+=' /home/ns/gd/scripts/sendPushoverTwitchAlert.sh "'+s+'"'
        uqp.run(cmd)
    }
}
