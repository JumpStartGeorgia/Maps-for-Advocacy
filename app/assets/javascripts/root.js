$(document).ready(function(){

  if (gon.front_page){
    $('#filter_venue').select2({width:'element'});

    $('#filter_venue').on('change', function(e){
      e.preventDefault();

      document.location = UpdateQueryString(gon.find_evaluations_path, 'venue_category_id', $('#filter_venue').val());
    });

  }
});