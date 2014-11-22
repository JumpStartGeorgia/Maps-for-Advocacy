$(document).ready(function(){

  function resize_front_page(){
    // make sure boxes are centered
    $('#front-page div#front-page-container').height($(window).height() - $('footer').height() - 90);
    $('#filter_venue').select2({width:'element'});

    // make the left buttons the size width
    widths = [];
    $('#front-page #text-links li a').each(function(){
      widths.push($(this).width());
    });
    $('#front-page #text-links li a').each(function(){
      $(this).width(Math.max.apply(Math, widths));
    });

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