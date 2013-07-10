function NoteEditingController() {
    var placeholding = false;
    var editingMode = 0;
    var previousEditingMode = 0;
    var previousSelection;
}

//
// Initialization
//

NoteEditingController.prototype.DOMDidLoad = function() {
    $('#categories').change(function() {
        bridge.send({
            eventName:'postCategoryChanged',
            value:$(this).val()
        });

        this.updateUI();
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
        this.updateUI();
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

    this.updateUI();
};

NoteEditingController.prototype.updateUI = function() {

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

    
};

//
// Bridge management
//

NoteEditingController.prototype.bridgeDidReceiveMessage = function(message, responseCallback) {
    configureWithInfo(message);

    $('#title').focus();
};

//
// Cursor
//
NoteEditingController.prototype.getElementContainingCaret = function() {
    var node = document.getSelection().anchorNode;
    var startNode = (node.nodeType == 3 ? node.parentNode : node);
    return startNode;     
};

NoteEditingController.prototype.getCaretCharacterOffsetWithin = function(element) {
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
};

NoteEditingController.prototype.moveCaretToEndOf = function(element) {
    var textRange = document.createRange();
    textRange.selectNodeContents(element);
    textRange.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(textRange);
};

//
// Document properties
//

NoteEditingController.prototype.getTitle = function() {
    if( placeholding ) {
        return '';
    }
    else {
        return $('#title').html();
    }
};

NoteEditingController.prototype.setTitle = function(title) {
    $('#title').html(title);
};


NoteEditingController.prototype.getContent = function(first_argument) {
    return $('#content').html();
};

NoteEditingController.prototype.setContent = function(content) {
    $('#content').html(content);
};

NoteEditingController.prototype.setPlaceholderString = function(placeholder) {
    $('#titlePlaceholder').text(placeholder);
};

NoteEditingController.prototype.setPlaceholding = function(shouldPlacehold) {
    placeholding = shouldPlacehold;

    if( placeholding ) {
        $('#titlePlaceholder').show();
        $('title').attr('class','alignLeft');
    }
    else {
        $('#titlePlaceholder').hide();
    }
};

NoteEditingController.prototype.setCategories = function(categories) {
    $('#categories').empty();
    categories.forEach(function(category, index) {
        $('#categories').append('<option value="' + category + '">' + category + '</option>');
    });
};

NoteEditingController.prototype.selectCategory = function(categories) {
    $('#categories').val(category);
};

NoteEditingController.prototype.getSelectedCategory = function() {
    return $('#categories').val();
};

NoteEditingController.prototype.getTopRightLines = function(lines) {
    return $('#topRightLines').html();
};

NoteEditingController.prototype.setTopRightLines = function(lines) {
    $('#topRightLines').html(lines);
};

NoteEditingController.prototype.setEditingMode = function(mode) {
    previousEditingMode = editingMode;
    editingMode = mode;

    updateUI();
};

NoteEditingController.prototype.configureWithInfo = function(info) {
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
};

//
// Editing
//

NoteEditingController.prototype.alignLeft = function() {
    $(getElementContainingCaret()).attr('class','alignLeft');
};

NoteEditingController.prototype.alignRight = function() {
    $(getElementContainingCaret()).attr('class','alignRight');
};

NoteEditingController.prototype.alignCenter = function() {
    $(getElementContainingCaret()).attr('class','alignCenter');
};

NoteEditingController.prototype.insertImageWithBase64 = function(src,width,height) {
    var imgObject = createResizableDraggableImageElement(src,width,height);

    document.getSelection().getRangeAt(0).insertNode(imgObject[0]);

    return imgObject;
    
};

NoteEditingController.prototype.createResizableDraggableImageElement = function(src, width, height) {
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
};

var App = new NoteEditingController();
NoteEditingController.prototype = new BridgedWebApp(App);
