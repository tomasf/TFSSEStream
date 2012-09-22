TFSSEStream provides a simple way to handle Server-Sent Events streams.

Create a `TFSSEStreamHandler`, set its `connectionHandler` property and add it as a request handler in your `WAApplication` subclass. The connection handler block is called whenever a new client connects. You can inspect the stream and its request. Keep a reference to the stream so you can use it later and return `YES`. Return `NO` to reject the connection.

To send data to the client, use the `sendMessage:event:ID:` method. The `event` and `ID` parameters are optional. Attach a block to the `closeHandler` property to handle the client closing the connection.