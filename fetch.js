$(document).ready(function(){
	$.getJSON(
	'fetch.php',
		function(result){
			$('#DT_RowId-').empty();
			$.each(result.result, function(){
				$('#DT_RowId-').append('<td>'+this['updated_at']+'</td>'+'<td>'+this['name']+'</td>'+'<td>'+this['description']+'</td>');
			});
		}
	);
});