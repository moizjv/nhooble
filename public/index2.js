
$(function(){

$( "#queryForm" ).submit(function( event ) {
  $("#solution").html('<table id="dynamicTable" align="center" style="padding-top: 20px;"></table>');
  $.ajax({
  type: "POST",
  url: 'queryResolver2',
  data: { field: $('#query').val() },
  
  error : function() {
  	$("#dynamicTable").append('<tr><td>No result found</td><tr>');
  },

  success: function(data) {
	
	var dataJson = eval("(" + data + ")");
		
	$.each(dataJson,function(index,val){
		$("#dynamicTable").append('<tr><td><a href="/docs/'+index+'">'+index+'</td><td>'+val+'</td><tr>');
	});
	
  }
  });
event.preventDefault();
});

});
