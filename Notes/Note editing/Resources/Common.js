var placeholding = false;
var bridge;
var domLoaded = false;

function alignLeft() {
    $(getElementContainingCaret()).attr('class','alignLeft');
}

function alignRight() {
    $(getElementContainingCaret()).attr('class','alignRight');
}

function alignCenter() {
    $(getElementContainingCaret()).attr('class','alignCenter');
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
        $('title').attr('class','alignLeft');
    }
    else {
        $('#titlePlaceholder').hide();
    }
}

function setCategories(categories) {
    $('#categories').empty();
    categories.forEach(function(category, index) {
        $('#categories').append('<option value="' + category + '">' + category + '</option>');
    });
}

function selectCategory(category) {
    $('#categories').val(category);
}

function getSelectedCategory() {
    return $('#categories').val();
}

function getTopRightLines(lines) {
    return $('#topRightLines').html();
}

function setTopRightLines(lines) {
    $('#topRightLines').html(lines);
}

function configureWithInfo(info) {
    if( info.title !== undefined ) {
        setTitle(info.title);
    }
    if( info.placeholderString !== undefined ) {
        setPlaceholderString(info.placeholderString);    
    }
    if( info.content !== undefined ) {
        setContent(info.content);
    }
    if( info.categories !== undefined ) {
        setCategories(info.categories);
    }
    if( info.selectedCategory !== undefined ) {
        selectCategory(info.selectedCategory);    
    }
    if( info.topRightLines !== undefined ) {
        setTopRightLines(info.topRightLines);
    }

    updateUI();
}

function updateUI() {
    if( $('#title').text().length ) {
        setPlaceholding(false);
    }
    else {
        setPlaceholding(true);
    }

    var category = getSelectedCategory();
    if( category == 'Class Notes' ) {
        $('#topRightLines').hide();
    }
    else if( category == 'Assignments' ) {
        $('#topRightLines').show();
    }
}

function getElementContainingCaret() {
    var node = document.getSelection().anchorNode;
    var startNode = (node.nodeType == 3 ? node.parentNode : node);
    return startNode;
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
        configureWithInfo(message);

        $('#title').focus();
    });
    if( domLoaded ) {
        bridge.send('DOMDidLoad');
    }
}, false);

$(function() {
    $('#categories').change(function() {
        bridge.send({
            eventName:'postCategoryChanged',
            value:$(this).val()
        });

        updateUI();
    });

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

