var placeholding = false,
    bridge,
    domLoaded = false,
    editingMode = 0,
    previousEditingMode = 0,
    previousSelection,
    searchResultApplier;

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

function getPlainTextContent() {
    return $('#content').text();
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

function setEditingMode(mode) {
    previousEditingMode = editingMode;
    editingMode = mode;

    updateUI();
}

function createResizableDraggableImageElement(src,width,height) {
    var img = document.createElement('div');
    var imgObject = $(img);

    imgObject.append(['<div class="ui-resizable-handle ui-resizable-nw" id="nwgrip"></div>',
                     '<div class="ui-resizable-handle ui-resizable-ne" id="negrip"></div>',
                     '<div class="ui-resizable-handle ui-resizable-sw" id="swgrip"></div>',
                     '<div class="ui-resizable-handle ui-resizable-se" id="segrip"></div>'].join('\n'));
    imgObject.attr('style','display: inline-block; background-size: 100% 100% !important; background: no-repeat url("' + src + '"); width:'+width+'px; height:'+height+'px; overflow:hidden;');
    imgObject.resizable({
        handles: {
        'ne': '#negrip',
        'se': '#segrip',
        'sw': '#swgrip',
        'nw': '#nwgrip'
        }
    });
    imgObject.draggable({
        snap:"#contentContainer",
        scroll: true
    });

    return imgObject;
}

function insertImageWithBase64(src,width,height) {
    var imgObject = createResizableDraggableImageElement(src,width,height);

    document.getSelection().getRangeAt(0).insertNode(imgObject[0]);

    return imgObject;
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
    if( info.editingMode !== undefined ) {
        setEditingMode(info.editingMode);
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

    var canvasObject = $('#simple_sketch');
    var canvas = canvasObject[0];
    var ctx = canvas.getContext('2d');

    if( editingMode == 0 ) {

        if( previousEditingMode == 1 ) {

            var boundaries = { };

            /* trim transparent pixels and save boundaries */
            cq('#simple_sketch').trim(null, boundaries);

            var imgObject = createResizableDraggableImageElement($('#simple_sketch')[0].toDataURL(), boundaries.width, boundaries.height);
            imgObject.css('position', 'absolute');
            imgObject.css('top',boundaries.top);
            imgObject.css('left',boundaries.left);

            $('.notepad').append(imgObject);

            canvasObject.sketch().clear();
        }
        
        $('#simple_sketch').hide();
        
    }
    else if( editingMode == 1 ) {
        
        if( document.getSelection().rangeCount ) {
            previousSelection = document.getSelection().getRangeAt(0).cloneRange();
        }

        $(':focus').blur();

        var notepad = $('.notepad');
        ctx.canvas.width  = notepad.width();
        ctx.canvas.height = notepad.height();

        $('#simple_sketch').show();
        
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

function focusAndSelectTitle() {
    moveCaretToEndOf($('#title').get(0));
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

function doSearch(searchTerm) {
    var range = rangy.createRange();
    var options = {
        caseSensitive: false
    };
    range.selectNodeContents($('#content').get(0));
    searchResultApplier.undoToRange(range);
    if( searchTerm !== "" ) {
        while( range.findText(searchTerm, options) ) {
            searchResultApplier.applyToRange(range);
            range.collapse(false);
        }
    }
}

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
        bridge.send({
            eventName:'titleChanged',
            value:$(this).text()
        });
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

    $('#simple_sketch').sketch();
    cq('#simple_sketch');

    rangy.init();
    searchResultApplier = rangy.createCssClassApplier("searchResult");

    // setEditingMode(1);

    updateUI();

    if( bridge === undefined ) {
        domLoaded = true;
    }
    else {
        bridge.send('DOMDidLoad');
    }
});
