var placeholding = false;
var bridge;
var domLoaded = false;

function alignLeft() {
    $(':focus').attr('alignleft');
}

function alignRight() {
    $(':focus').attr('alignright');
}

function alignCenter() {
    $(':focus').attr('aligncenter');
}

function getTitle() {
    if( placeholding ) {
        return '';
    }
    else {
        return $('#title').html();
    }
}

function setTitle(title) {
	$('#title').html(title);
}

function getContent() {
	return $('#content').html();
}

function setContent(content) {
	$('#content').html(content);
}

function setPlaceholderString(placeholder) {
    $('#titlePlaceholder').text(placeholder);
}

function setPlaceholding(shouldPlacehold) {
    placeholding = shouldPlacehold;
    
    if( placeholding ) {
        $('#titlePlaceholder').show();
    }
    else {
        $('#titlePlaceholder').hide();
    }
}

function updateUI() {
    if( $('#title').text().length ) {
        setPlaceholding(false);
    }
    else {
        setPlaceholding(true);
    }
}

function getCaretCharacterOffsetWithin(element) {
    var caretOffset = 0;
    if (typeof window.getSelection != "undefined") {
        var range = window.getSelection().getRangeAt(0);
        var preCaretRange = range.cloneRange();
        preCaretRange.selectNodeContents(element);
        preCaretRange.setEnd(range.endContainer, range.endOffset);
        caretOffset = preCaretRange.toString().length;
    } else if (typeof document.selection != "undefined" && document.selection.type != "Control") {
        var textRange = document.selection.createRange();
        var preCaretTextRange = document.body.createTextRange();
        preCaretTextRange.moveToElementText(element);
        preCaretTextRange.setEndPoint("EndToEnd", textRange);
        caretOffset = preCaretTextRange.text.length;
    }
    return caretOffset;
}

function moveCaretToEndOf(element) {
    var textRange = document.createRange();
    textRange.selectNodeContents(element);
    textRange.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(textRange);
}

document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady(event) {
    bridge = event.bridge;

    bridge.init(function(message, responseCallback) {
        alert('Received message: ' + message)   ;
    });
    if( domLoaded ) {
        bridge.send('DOMDidLoad');
    }

}, false);

$(function() {
    $('#title').focus();

    $('#titlePlaceholder').click(function() {
        $('#title').focus();
    });
  
    $('#title').keydown(function(event) {
        if( event.which == 13 ) {
            $('#content').focus();
            return false;
        }
    });
    $('#title').keyup(function(event) {
        updateUI();
    });

	$('#content').keydown(function(event) {
		if( event.which == 13 ) {
		}
        else if( event.which == 8 && getCaretCharacterOffsetWithin($('#content').get(0))  == 0 ) {
            var title = $('#title');
            title.focus();
            moveCaretToEndOf(title.get(0));
            return false;
        }
	});

    updateUI();

    if( bridge === undefined ) {
        domLoaded = true;
    }
    else {
        bridge.send('DOMDidLoad');
    }

});

