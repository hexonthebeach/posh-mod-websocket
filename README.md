# POSH-MOD-WEBSOCKET
PowerShell module for using a WebSocket service

## Description
Make interaction with a Websocket service easy by abstracting away all the hassle, hiding that behind nice functions.

## Installation
Clone the project to a directory that can be read by your script.

``Import-Module "path\to\module.psm1"`` 

## How
The module contains the bare essentials for setting up a websocket connection, you will need to apply any kind of logic around the functions yourself.

These Functions are available when you imported the module :

``Connect-Websocket`` -Endpoint

``Test-Websocket``

``Disconnect-Websocket``

``Send-Message`` -Message

``Receive-Message``

In the examples folder I added a script connecting to a public websocket service.

Here is how it basicly fits together :
```
Connect-Websocket -Endpoint "wss://any.websocket.service"
Send-Message -Message '{"subscription_or":"authentication_message"}'
while( Test-Websocket ){
    Receive-Message
}
Disconnect-Websocket
```

### Thanks
wragg.io