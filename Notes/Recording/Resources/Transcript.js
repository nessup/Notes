function TranscriptController() {
	var content = null;
	var domLoaded = false;

	this.DOMDidLoad = function() {
		domLoaded = true;
		this.updateUI();
	}

	this.bridgeDidReceiveMessage = function(message, responseCallback) {
		// var self = this;
		for( var name in message ) {
			if( message.hasOwnProperty(name) ) {
				if( name === "content" ) {
					// alert('self = ' + (self instanceof TranscriptController) + ', this = ' + (this instanceof TranscriptController));
					// alert(message.content);
					content = message.content;
				}
			}
		}
		this.updateUI();
	}

	this.updateUI = function() {
		$('#content').html(content);
	}

	this.playSegmentAtIndex = function(index) {
		AppHelper.getBridge().send({
			eventName: 'playSegmentAtIndex',
			value: index
		});
	}

	this.setContent = function(content) {
		$('#content').html(content);
	}
}

var App = new TranscriptController();
var AppHelper = new BridgedAppHelper(App);
