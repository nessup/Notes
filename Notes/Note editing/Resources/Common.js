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
	return $('h1').html();
}

function setTitle(title) {
	$('h1').html(title);
}

function getContent() {
	return $('#content').html();
}

function setContent(content) {
	$('#content').html(content);
}

$(function() {
	$('p').keydown(function(event) {
		if( event.which == 13 ) {
		}
	});
});
