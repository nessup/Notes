function BridgedWebApp(callbackBind) {
      this.bridge = null;
      this.domLoaded = false;

      document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady(event) {
            this.bridge = event.bridge;

            bridge.init(function(message, responseCallback) {
                  callbackBind.bridgeDidReceiveMessage(message, responseCallback);
            });
            if( domLoaded ) {
                  bridge.send('DOMDidLoad');
            }
      }, false);

      $(function() {
            callbackBind.domLoaded = true;
            callbackBind.DOMDidLoad();
      });
}

BridgedWebApp.prototype.DOMDidLoad = function() {

}

BridgedWebApp.prototype.bridgeDidReceiveMessage = function(message, responseCallback) {

}
