function NoteEditingController () {
    var placeholding = false;
    var editingMode = 1;
    var previousEditingMode = 0;
    var previousSelection;
    var myScriptAPIKey = "49b23d6a-3a28-40a3-a93d-7a76b8cb7288";
    var scratchDrawingDiv = null;
    var lastSelectedImage = null;

    //
    // Initialization
    //
    this.DOMDidLoad = function() {
        var self = this;
        $('#categories').change(function() {
            AppHelper.getBridge().send({
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
            AppHelper.getBridge().send({
                eventName: 'titleChanged',
                value: $(this).text()
            });
        });

        $('#content').keydown(function(event) {
            if( event.which == 13 ) {
            }
            else if( event.which == 8 && getCaretCharacterOffsetWithin($('#content').get(0))  === 0 ) {
                var title = $('#title');
                title.focus();
                self.moveCaretToEndOf(title.get(0));
                return false;
            }
        });

        var canvas = $('#simple_sketch');
        canvas.sketch();
        cq('#simple_sketch');
        canvas.strokes = [];
        canvas.strokesSave = [];
        $('#simple_sketch').addWriteHandlers(this, canvas.strokes, canvas.strokesSave);

        $(document).on("onHideAllPopovers", function(event) {
            self.deselectAllImageObjects();
        });

        MathJax.Hub.Config({
             "HTML-CSS": {
               styles: {
                 '.MathJax_Display': {
                    "margin": 0
                  }
               }
             }
         });

        this.updateUI();
    };

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

        if( editingMode === 0 ) {

            if( previousEditingMode == 1 ) {

                var boundaries = { };

                /* trim transparent pixels and save boundaries */
                cq('#simple_sketch').trim(null, boundaries);

                if( boundaries.top === undefined || boundaries.left === undefined || boundaries.width === undefined || boundaries.height === undefined ) {
                    console.error('Invalid boundaries');
                }
                else {
                    var imgObject = this.createResizableDraggableImageElement(scratchDrawingDiv, $('#simple_sketch')[0].toDataURL(), boundaries.width, boundaries.height);
                    scratchDrawingDiv = null;
                    imgObject.css('position', 'absolute');
                    imgObject.css('top',boundaries.top);
                    imgObject.css('left',boundaries.left);

                    imgObject.popover({
                        title: '<a class="convert-to-equation">Convert to equation</a>'
                    });

                    $('.convert-to-equation').click(function() {
                        lastSelectedImage.find('.handwriting').hide();
                        var mathjax = lastSelectedImage.find('.mathjax');
                        mathjax.show();
                        lastSelectedImage.width(mathjax.find('.MathJax_Display nobr').width());
                    });

                    $('.notepad').append(imgObject);

                    canvasObject.sketch().clear();
                }
            }

            $('#simple_sketch').hide();

        }
        else if( editingMode == 1 ) {

            if (!scratchDrawingDiv) {
                scratchDrawingDiv = $(document.createElement('div')).appendTo($('body')).hide();
            }

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
    // Handwriting recognition
    //

    this.recognize = function(strokes) {
        var myDrawingDiv = scratchDrawingDiv;
        var options = {
            type: ["LATEX"]
        };

        var url = "https://myscript-webservices.visionobjects.com/api/myscript/v2.0/equation/doSimpleRecognition.json";

        var jsonPost =  {
            "components" : strokes,
            "resultTypes" : options.type
        };
        var jsonPostString = JSON.stringify(jsonPost);

        myDrawingDiv.dataset('jsonPost', jsonPostString);

        /** Send data to POST. Give your API key as supplied on registration, or the 
        * server will not recognize you as a valid user. */
        var data = {
            "apiKey" : myScriptAPIKey,
            "equationInput" : jsonPostString
        };

        /** Display the "wait" symbol while processing is underway. */
        $("#loading").show();
        /** Post request.   */
        var self = this;
        $.post(url, data, function handleResponse(response) {

            var mathJaxInput = "$$";

            var i;
            for(i=0; i<response.result.results.length; i++) {
                mathJaxInput = mathJaxInput + response.result.results[i].value;
            }
            mathJaxInput = mathJaxInput + "$$";

            myDrawingDiv.dataset('mathJaxInput', mathJaxInput);

        }, "json").error(function(XMLHttpRequest, textStatus) {
            $("#loading").text(textStatus +" : "+ XMLHttpRequest.responseText);
            // this.displayResult(XMLHttpRequest.responseText);



            $("#loading").hide();
        });
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

    // this.insertImageWithBase64 = function(src,width,height) {
    //     var imgObject = createResizableDraggableImageElement(scratchDrawingDiv src,width,height);

    //     document.getSelection().getRangeAt(0).insertNode(imgObject[0]);

    //     return imgObject;
    // };

    this.createResizableDraggableImageElement = function(containerObject, src, width, height) {
        var self = this;

        containerObject.attr('class', 'drawn-image unselected-image');

        containerObject.append(['<div class="ui-resizable-handle ui-resizable-nw"></div>',
         '<div class="ui-resizable-handle ui-resizable-ne"></div>',
         '<div class="ui-resizable-handle ui-resizable-sw"></div>',
         '<div class="ui-resizable-handle ui-resizable-se"></div>'].join('\n'));

        containerObject.attr('style','display: inline-block; overflow: auto;');

        containerObject.resizable({
            handles: {
                'ne': '.ui-resizable-ne',
                'se': '.ui-resizable-se',
                'sw': '.ui-resizable-sw',
                'nw': '.ui-resizable-nw'
            }
        });
        containerObject.draggable({
            snap:"#contentContainer",
            scroll: true,
            start: function() {
                $(this).popover('fadeOut');
            }
        });

        var touchStartHandler = function(event) {
            event.preventDefault();
            event.stopPropagation();
            self.selectImageObject($(this));
        };
        var touchEndHandler = function(event) {
            $(this).popover('show');
        };
        containerObject.bind('touchstart', touchStartHandler).bind('click', touchStartHandler);
        containerObject.bind('touchend', touchEndHandler).bind('click', touchEndHandler);

        var imgObject = $('<img />', {class: 'handwriting', src: src}).appendTo(containerObject);
        imgObject.attr('style','display: inline-block; overflow:auto;');

        var mathJaxObject = $('<div />', {class: 'mathjax'}).appendTo(containerObject).hide();
        mathJaxObject.text(containerObject.dataset('mathJaxInput'));
        mathJaxObject.css('font-size', (height - 20) + 'px');
        MathJax.Hub.Queue([ 'Typeset', MathJax.Hub, mathJaxObject.get(0)]);

        return containerObject;
    };

    this.selectImageObject = function(imgObject) {
        var self = this;
        imgObject.popover('setOption', 'onHideAll', function() {
            self.deselectAllImageObjects();
        });
        imgObject.removeClass('unselected-image');
        imgObject.addClass('selected-image');
        lastSelectedImage = imgObject;
    };

    this.deselectAllImageObjects = function() {
        // $('.drawn-image').each(function(i) {
        // });
        var $objects = $('.selected-image');
        $objects.removeClass('selected-image');
        $objects.addClass('unselected-image');
        lastSelectedImage = null;
    };

    //
    // Utilities
    //

    // function mapThat( mappedObject, obj ) {
    //     Object.keys( obj ).forEach( function( key ) {
    //         if ( typeof obj[ key ] === 'object' ) {
    //             mapThat( obj[ key ], mappedObject );
    //         }
    //         else {
    //             mappedObject[ key.toLowerCase() ] = obj[ key ];
    //         }
    //     } );
    // }
}

var App = new NoteEditingController();
var AppHelper = new BridgedAppHelper(App);
