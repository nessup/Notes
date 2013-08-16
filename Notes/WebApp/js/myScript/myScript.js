/**
* Copyright (c) Vision Objects
* 
* This file contains an example of equation recognition, when used in
* conjunction with the other files in the samples, which let you create a 
* drawing canvas in an HTML file, where users can enter handwritten equations
* that will be sent to the MyScript recognition server.
* In brief, this sample creates a JSON request, based on the strokes collected in
* the HTML file. 
* It then sends the request to the MyScript recognition server, and retrieves and
* displays the results as LaTeX or MathML strings.
* This implementation is provided as-is. You will need to provide your personal
* API key, given to you on registration, if you want the request to succeed.
*
*/

/** Draw strokes in the canvas, as specified in the accompanying HTML file. */
$.fn.extend({
       addWriteHandlers: function(callbackObject, strokes, strokesSave) {
	      var stroke;
	      var canvas = this.get(0);
	      var ctx = canvas.getContext("2d");
	      var drawing = false;
	      var lastX, lastY;

	      var methods = {
		     start: function(x, y) {
			    stroke = {
				   "type":"stroke",
				   "x" : [x],
				   "y" : [y]
			    };
			    lastX = x;
			    lastY = y;
			    drawing = true;
		     },
		     move: function(x, y) {
			    if (drawing) {
				   ctx.beginPath();
				   ctx.moveTo(lastX, lastY);
				   ctx.lineTo(x, y);
				   ctx.stroke();
				   stroke.x.push(x);
				   stroke.y.push(y);
				   lastX = x;
				   lastY = y;
			    }
		     },
		     /**As soon as drawing finishes, the strokes are sent for recognition. */
			 end: function() {
			    if (drawing) {
				   drawing = false;
				   strokes.push(stroke);
				   while(strokesSave.length != 0) strokesSave.pop();
				   callbackObject.recognize(strokes);
			    }
		     }
	      };

/** Describes the writing events on the canvas, for mouse and touchscreen.	 */      
	      $(canvas).on("touchstart", function(event) {
		     event.preventDefault();
		     var offset = $(this).first().offset();
		     var touch = event.originalEvent.touches[0];
		     var x = touch.pageX - offset.left;
		     var y = touch.pageY - offset.top;
		     methods.start(x, y);
	      });
	      $(canvas).on("touchmove", function(event) {
		     event.preventDefault();
		     var offset = $(this).first().offset();
		     var touch = event.originalEvent.touches[0];
		     var x = touch.pageX - offset.left;
		     var y = touch.pageY - offset.top;
		     methods.move(x, y);
	      });
	      $("*").on("touchend", function(event) {
		     event.preventDefault();
		     methods.end();
	      });
	      $(canvas).on("mousedown", function(event) {
		     event.preventDefault();
		     var offset = $(this).first().offset();
		     var x = event.pageX - offset.left;
		     var y = event.pageY - offset.top;
		     methods.start(x, y);
	      });
	      $(canvas).on("mousemove", function(event) {
		     event.preventDefault();
		     var offset = $(this).first().offset();
		     var x = event.pageX - offset.left;
		     var y = event.pageY - offset.top;
		     methods.move(x, y);
	      });
	      $("*").on("mouseup", function(event) {
		     event.preventDefault();
		     methods.end();
	      });
       },
	   /** Used to re-draw previously drawn strokes, if the redo button is activated. The strokes.Save function retains the last canvas entry to allow for this. */
       paintStroke: function(ctx, stroke) {
	      ctx.beginPath();
	      var lastX = stroke.x[0], lastY = stroke.y[0];
	      ctx.moveTo(stroke.x[0],stroke.y[0]);
	      
	      var i;
	      for(i=1; i<stroke.x.length; i++) {
		     ctx.lineTo(stroke.x[i],stroke.y[i]);
		     ctx.moveTo(stroke.x[i],stroke.y[i]);		     
		     lastX = stroke.x[i];
		     lastY = stroke.y[i];		     
	      }
	      ctx.stroke();
       }
});

