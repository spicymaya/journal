$(document).ready(function(){	
	
	$('.datepicker').datepicker();
	$(document).keyup(function(e) {
  	if (e.keyCode == 27) { // esc
  		$('.datepicker').datepicker('hide'); 
		}   
	});
	$('.datepicker').on('changeDate', function() {
		$('.datepicker').datepicker('hide'); 
	})
});