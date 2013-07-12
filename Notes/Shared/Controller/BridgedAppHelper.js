console.log = function(log) {
      alert(log);
}
console.debug = console.log;
console.info = console.log;
console.warn = console.log;
console.error = console.log;

window.onerror = function(error, url, line) {
      console.log('error: ' + error +  ' url: ' + url + ' line: ' + line);
};

function BridgedAppHelper(callbackBind) {    
      var bridge = null;
      var domLoaded = false;

      this.getBridge = function() {
            return bridge;
      }

      var self = this;
      document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady(event) {
            bridge = event.bridge;

            bridge.init(function(message, responseCallback) {
                  callbackBind.bridgeDidReceiveMessage.call(callbackBind, message, responseCallback);
            });
            if( domLoaded ) {
                  bridge.send('DOMDidLoad');
            }
      }, false);

      $(function() {
            domLoaded = true;
            callbackBind.DOMDidLoad.call(callbackBind);

            if( bridge ) {
                  bridge.send('DOMDidLoad');
            }
      });
}
