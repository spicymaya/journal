$(document).ready(function(){	
var last_key_pressed;	
var dlp=document.location.pathname;
	$('.datepicker').datepicker();
	$(document).keyup(function(e) {
  	if (e.keyCode == 27) { // esc
  		$('.datepicker').datepicker('hide'); 
		}
		else if (e.keyCode == 13 && last_key_pressed==13) {
			var dlp_split=dlp.split("/");
			if (dlp.indexOf('/posts') >= 0 && dlp.indexOf('/edit') < 0) {
          post_id = $('.post').attr('id').replace('post_', '')
          // post_id=encodeURIComponent(post_id);
          var string_url = "/posts/" + post_id + "/edit";
          // redirect
          window.location = string_url; 
      }   
		} 
		last_key_pressed=e.keyCode;	
	});
	$('.datepicker').on('changeDate', function() {
		$('.datepicker').datepicker('hide'); 
	})
	// $(".cycle-slideshow").children('img').attr('src')

	
});