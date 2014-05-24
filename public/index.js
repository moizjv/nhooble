
$(function(){

$( "#queryForm" ).submit(function( event ) {
  $.ajax({
  type: "POST",
  url: 'queryResolver',
  data: { field: $('#query').val() },
//$('#query').val(),
  success: function(data) {
	$("#solution").html("");
	$("#solution").append("<div>"+data+"</div>");
	//alert(data);
  }
  });
event.preventDefault();
});

});
