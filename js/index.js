


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
	
	//var dataJson = eval("(" + data + ")");
	data=data.sort(function(a,b) {
		return a[1]-b[1];
	});
		
	$.each(data,function(index,val){
		$("#dynamicTable").append('<tr><td><a href="/docs/'+data+'">'+data+'</td><tr>');
	});
	
  }
  });
event.preventDefault();
});

});



