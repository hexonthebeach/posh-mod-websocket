##
# PowerShell Module for a WebSocket connection
##

$Script:WS = New-Object System.Net.WebSockets.ClientWebSocket
$Script:CT = New-Object System.Threading.CancellationToken
$script:Conn = $null

<#
 .Synopsis
  Connect to a websocket endpoint

 .Description
  Try to set up a connection to the provided endpoint

 .Parameter Endpoint
  The full uri to the websocket endpoint
#>
Function Connect-Websocket {
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Endpoint
    )

    $Script:Conn = $Script:WS.ConnectAsync($Endpoint, $Script:CT)
    While (-not $Script:Conn.IsCompleted) {
        Start-Sleep -Milliseconds 100
    }

    return ($Script:WS.State -eq 'Open')
}

<#
 .Synopsis
  Get Websocket State

 .Description
  Find the current State of the Websocket connection

 .Example
  # perform stuff while the connection is available
  While (Test-Websocket) {
    Write-Host (Receive-Message)    
  }
#>
Function Test-Websocket {
    return ($Script:WS.State -eq 'Open')
}

<#
 .Synopsis
  Send a Message to a Websocket endpoint

 .Description
  Convert a Message String to a ByteArray and push it on the open Websocket

 .Parameter Message
  The Message to send
#>
Function Send-Message {
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Message
    )

    $Array = [system.Text.Encoding]::UTF8.GetBytes($Message)
    $Sub = New-Object System.ArraySegment[byte] -ArgumentList @(,$Array)

    $Send = $Script:WS.SendAsync($Sub, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $Script:CT)

    return $Send.IsCompleted
}

<#
 .Synopsis
  Receive Messages from a Websocket connection

 .Description
  Wait for Messages to arrive and return that ByteArray to as a String

 .Example
  # wait for a message
  $msg = Receive-Message
#>
Function Receive-Message {
    $Size = 1024
    $Array = [byte[]] @(,0) * $Size
    $Recv = New-Object System.ArraySegment[byte] -ArgumentList @(,$Array)

    $content = ""

    Do {
        $Script:Conn = $Script:WS.ReceiveAsync($Recv, $Script:CT)
        While (-not $Script:Conn.IsCompleted) { Start-Sleep -Milliseconds 100 }

        $Recv.Array[0..($Script:Conn.Result.Count - 1)] |ForEach-Object { $content += [char]$_ }

    } Until ($Script:Conn.Result.Count -lt $Size)

    return $content
}

<#
 .Synopsis
  Receive Messages from a Websocket connection

 .Description
  Wait for Messages to arrive and return that ByteArray to as a String

 .Example
  # close a websocket connection
  Disconnect-Websocket
#>
Function Disconnect-Websocket {
    If ($Script:WS) { 
        $Script:WS.Dispose()
    }

    return (-not $Script:WS)
}

Export-ModuleMember Connect-Websocket,Test-Websocket,Disconnect-Websocket,Send-Message,Receive-Message