$(document).ready(function(){

  function resize_front_page(){
    $('#front-page div#front-page-container').height($(window).height() - $('footer').height() - 90);
    $('#filter_venue').select2({width:'element'});
  }

  if (gon.front_page){
    
    resize_front_page();
    $(window).bind('resize', resize_front_page);

    $('#filter_venue').select2({width:'element'});

    $('#filter_venue').on('change', function(e){
      e.preventDefault();

      document.location = UpdateQueryString(gon.find_evaluations_path, 'venue_category_id', $('#filter_venue').val());
    });

  }
});