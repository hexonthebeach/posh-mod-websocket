# import the websocket module
Import-Module ..\src\posh-mod-websocket.psm1

$url = "wss://ws-feed.gdax.com"

Try{
    # get connected
    if( Connect-Websocket -Endpoint $url ){
        Write-Host "Connected to $($url)"
    }

    # make a subscription message
    $subscribe_msg = (@{
        "type" = "subscribe"
        "product_ids" = @("ETH-EUR","ETH-BTC")
        "channels" = @("ticker")
    } |ConvertTo-Json)
    # send the subscription so we will get some incoming messages
    Send-Message $subscribe_msg

    # main loop for performing actions on incoming messages
    While (Test-Websocket) {
        # wait for a message
        $incoming_msg = Receive-Message

        $message = ($incoming_msg | convertfrom-json)

        # add mesage type property dependant logic
        Switch ($message.type){
            "subscriptions" { Write-Host $message -BackgroundColor Cyan }
            "ticker" { Write-Host $message -BackgroundColor DarkGreen }
            default { Write-Host "No action specified for $($message.type) event" }
        }
    }
}catch{
    Write-Error $_.Exception.Message
}Finally{
    Disconnect-Websocket
}
Write-Host "done"