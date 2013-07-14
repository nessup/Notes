function NoteEditingController () {
    var placeholding = false;
    var editingMode = 0;
    var previousEditingMode = 0;
    var previousSelection;

    //
    // Initialization
    //
    this.DOMDidLoad = function() {
        var self = this;
        $('#categories').change(function() {
            bridge.send({
                eventName:'postCategoryChanged',
                value:$(this).val()
            });

            self.updateUI();
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
            self.updateUI();
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
    }

    this.updateUI = function() {
        if( $('#title').text().length ) {
            this.setPlaceholding(false);
        }
        else {
            this.setPlaceholding(true);
        }

        var category = this.getSelectedCategory();
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

                var imgObject = this.createResizableDraggableImageElement($('#simple_sketch')[0].toDataURL(), boundaries.width, boundaries.height);
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

    this.bridgeDidReceiveMessage = function(message, responseCallback) {
        this.configureWithInfo(message);

        $('#title').focus();
    };

    //
    // Cursor
    //
    this.getElementContainingCaret = function() {
        var node = document.getSelection().anchorNode;
        var startNode = (node.nodeType == 3 ? node.parentNode : node);
        return startNode;     
    };

    this.getCaretCharacterOffsetWithin = function(element) {
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

    this.moveCaretToEndOf = function(element) {
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

    this.getTitle = function() {
        if( placeholding ) {
            return '';
        }
        else {
            return $('#title').html();
        }
    };

    this.setTitle = function(title) {
        $('#title').html(title);
    };


    this.getContent = function(first_argument) {
        return $('#content').html();
    };

    this.setContent = function(content) {
        $('#content').html(content);
    };

    this.setPlaceholderString = function(placeholder) {
        $('#titlePlaceholder').text(placeholder);
    };

    this.setPlaceholding = function(shouldPlacehold) {
        placeholding = shouldPlacehold;

        if( placeholding ) {
            $('#titlePlaceholder').show();
            $('title').attr('class','alignLeft');
        }
        else {
            $('#titlePlaceholder').hide();
        }
    };

    this.setCategories = function(categories) {
        $('#categories').empty();
        categories.forEach(function(category, index) {
            $('#categories').append('<option value="' + category + '">' + category + '</option>');
        });
    };

    this.selectCategory = function(category) {
        $('#categories').val(category);
    };

    this.getSelectedCategory = function() {
        return $('#categories').val();
    };

    this.getTopRightLines = function(lines) {
        return $('#topRightLines').html();
    };

    this.setTopRightLines = function(lines) {
        $('#topRightLines').html(lines);
    };

    this.setEditingMode = function(mode) {
        previousEditingMode = editingMode;
        editingMode = mode;

        this.updateUI();
    };

    this.configureWithInfo = function(info) {
        if( info.title !== undefined ) {
            this.setTitle(info.title);
        }

        if( info.placeholderString !== undefined ) {
            this.setPlaceholderString(info.placeholderString);    
        }

        if( info.content !== undefined ) {
            this.setContent(info.content);
        }

        if( info.categories !== undefined ) {
            this.setCategories(info.categories);
        }

        if( info.selectedCategory !== undefined ) {
            this.selectCategory(info.selectedCategory);    
        }

        if( info.topRightLines !== undefined ) {
            this.setTopRightLines(info.topRightLines);
        }

        if( info.editingMode !== undefined ) {
            this.setEditingMode(info.editingMode);
        }

        this.updateUI();
    };

    //
    // Editing
    //

    this.alignLeft = function() {
        $(getElementContainingCaret()).attr('class','alignLeft');
    };

    this.alignRight = function() {
        $(getElementContainingCaret()).attr('class','alignRight');
    };

    this.alignCenter = function() {
        $(getElementContainingCaret()).attr('class','alignCenter');
    };

    this.insertImageWithBase64 = function(src,width,height) {
        var imgObject = createResizableDraggableImageElement(src,width,height);

        document.getSelection().getRangeAt(0).insertNode(imgObject[0]);

        return imgObject;
        
    };

    this.createResizableDraggableImageElement = function(src, width, height) {
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
}

var App = new NoteEditingController();
var AppHelper = new BridgedAppHelper(App);
