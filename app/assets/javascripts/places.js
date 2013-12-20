$(document).ready(function(){
  /*************************************************/
  /* venue filter on place form */
  if (gon.place_form_venue_filter){
    $('ul#venue_categories li a').click(function(){
      // turn off all lists
      $('#venue_category_lists .venue_category').addClass('accessibly-hidden');
      
      // turn on the correct list
      $('#venue_category_lists .venue_category[data-id="' + $(this).data('id') + '"]').removeClass('accessibly-hidden').focus();
      
    });

/*
    // custom css expression for a case-insensitive contains()
    jQuery.expr[':'].Contains = function(a,i,m){
      return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase())>=0;
    };


    $('#filter-input').change( function () {
      var filter = $(this).val();
      var list = '.venue-category ul';
      if(filter) {
        // this finds all links in a list that contain the input,
        // and hide the ones not containing the input while showing the ones that do
        $(list).find("a:not(:Contains(" + filter + "))").parent().slideUp().addClass('hidden').removeClass('visible');
        $(list).find("a:Contains(" + filter + ")").parent().slideDown().addClass('visible').removeClass('hidden');
        
      } else {
        $(list).find("li").slideDown().addClass('visible').removeClass('hidden');
      }

      // show number of matches
      $('.venue-filter-num-match').html($(list).find('li.visible').length + ' ' + gon.place_form_venue_num_match);

      // if no matches, hide everything
      // else, only show sections that have match in list
      if ($(list).find('li.visible').length == 0){
        $('.venue-category').slideUp();
      } else {
        // only category if have results
        $('.venue-category').each(function(){
          if ($(this).find('li.visible').length == 0){
            $(this).slideUp();
          }else{
            $(this).slideDown();
          }
        });
      }
      return false;
    })
    .keyup( function () {
      // fire the above change event after every letter
      $(this).change();
    });
*/
  }
  
  /* show name for place form */
  if (gon.show_place_name_form){
    $('form.place #place_name').change(function(){
      var name = $(this).val();
      var url = updateQueryStringParameter($('#place_name_next').attr('href'), 'name', name);

      if (name.length == 0){
        // hide the next button
        $('#place_name_next').attr('href', url).attr('aria-hidden', 'true');
      }else {
        // show the next button
        $('#place_name_next').attr('href', url).attr('aria-hidden', 'false');

      }
    })
    .keyup( function () {
      // fire the above change event after every letter
      $(this).change();
    });

  }  
  
  
  /* show map for place form */
  if (gon.show_place_form_map){
      map = L.map(gon.map_id).setView([gon.lat, gon.lon], gon.zoom);
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
		  map.attributionControl = false;
		  map.zoomControl = true;
		
      function onMapClick(e){
        reset_map();
        create_map_marker(e.latlng.lat, e.latlng.lng, null, true);
      }
      
      map.on('click', onMapClick);  
  }
  
  /* perform an address search */
  if (gon.address_search_path){
    /* if enter key is pressed do address search */
    $('input#address-search').keypress(function(event){
	    var keycode = (event.keyCode ? event.keyCode : event.which);
	    if(keycode == '13'){
		    search_for_address();
        return false;
	    }
     
    });
      
    $('#submit-address-search').click(function(){
      search_for_address();
		  return false;
    });
  }

  /*************************************************/
  /* actions for the evaluation form */
  if (gon.show_evaluation_form){
    /* show the evidence text fields as need */
    function show_question_evidence(ths){
      if ($(ths).is(':checked') && ($(ths).val() == '4' || $(ths).val() == '3') ) {
        $(ths).closest('div.venue_evaluation_question').find('input[type="text"]').attr('aria-hidden', 'true');
        $(ths).closest('div').find('input[type="text"]').attr('aria-hidden', 'false');
      } else{
        $(ths).closest('div.venue_evaluation_question').find('input[type="text"]').attr('aria-hidden', 'true');
      }
    }
  
    $('form.place div.venue_evaluation div.question-with-evidence input[type="radio"]').change(function(){
      show_question_evidence(this);
    });

    /* if any vields are already marked, show evidence if necessary */  
    $('form.place div.venue_evaluation div.question-with-evidence input[type="radio"]:checked').each(function(){
      show_question_evidence(this);
    });
  }


  /*************************************************/
  /* show map for place show */
  if (gon.show_place_map){
      map = L.map(gon.map_id).setView([gon.lat, gon.lon], gon.zoom);
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
		  map.attributionControl = false;
		  map.zoomControl = true;
		
      marker = L.marker([gon.lat, gon.lon]).addTo(map);

      // show popup
      if (gon.marker_popup){
        marker.bindPopup(gon.marker_popup).openPopup();
      }

  }
  


});
