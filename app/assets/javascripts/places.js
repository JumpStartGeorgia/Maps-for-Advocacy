$(document).ready(function(){
  // get the user coordinates
  function get_user_coordinates(position){
    load_place_form_map([position.coords.latitude, position.coords.longitude]);
  }

  function get_geolocation_error(error) {
    var errors = { 
      1: 'Permission denied',
      2: 'Position unavailable',
      3: 'Request timeout'
    };
    console.log("geo location error: " + errors[error.code]);
    load_place_form_map();
  }

  function load_place_form_map(coords){
    console.log("- coords " + coords);
    if (coords == undefined){
      console.log("- coords not passed in, using default gon coords");
      coords = [gon.lat, gon.lon];
    }
    
    map = L.map(gon.map_id).setView(coords, gon.zoom);
    L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
	  map.attributionControl = false;
	  map.zoomControl = true;
	
    function onMapClick(e){
      reset_map();
      create_map_marker(e.latlng.lat, e.latlng.lng, null, true);
    }
    
    map.on('click', onMapClick);  
  }

  /*************************************************/
  /* venue filter on place form */
  if (gon.place_form_venue_filter){
    $('ul#venue_categories li a').click(function(){
      // unmark all links as active
      $('ul#venue_categories li a').removeClass('active');
      // mark this link as active
      $(this).addClass('active');

      // turn off all lists
      $('#venue_category_lists .venue_category').addClass('accessibly-hidden');
      // turn on the correct list
      $('#venue_category_lists .venue_category[data-id="' + $(this).data('id') + '"]').removeClass('accessibly-hidden').focus();
     
      // make sure window is at the top
      $(window).scrollTop(0);
    });
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
    })
    .keypress(function(event){
	    var keycode = (event.keyCode ? event.keyCode : event.which);
	    if(keycode == '13'){
        return false;
	    }
    });

  }  
  
  
  /* show map for place form */
  if (gon.show_place_form_map){
      // if the user is using a browser that supports geolocation
      // use the current users coordinates
      if (navigator.geolocation){
        console.log('user can use geolocation');
        // not catching any errors for if there are some, the var coords will not change and that is ok
        navigator.geolocation.getCurrentPosition(get_user_coordinates, get_geolocation_error);
      } else{
        load_place_form_map();
      }  
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
      if ($(ths).is(':checked') && ($(ths).val() == gon.answer_yes || $(ths).val() == gon.answer_no) ) {
        $(ths).closest('div.venue_evaluation_question').find('input[type="text"]').attr('aria-hidden', 'true');
        $(ths).closest('div').find('input[type="text"]').attr('aria-hidden', 'false');
      } else{
        $(ths).closest('div.venue_evaluation_question').find('input[type="text"]').attr('aria-hidden', 'true');
      }
    }

    // show the submit button if at least one item is selected
    $('form.place div.venue_evaluation input[type="radio"]').change(function(){
      if ($('form.place div.venue_evaluation input[type="radio"]:checked').length == 0){
        $('form.place #submit-button').addClass('accessibly-hidden');
      }else{
        $('form.place #submit-button').removeClass('accessibly-hidden');
      }
    });
    
    // if exists question is marked as has, show the rest of the questions
    $('form.place div.venue_evaluation div.exists-question input[type="radio"]').change(function(){
      if (gon.answer_yes == $(this).val()){
        // show the questions
        $(this).closest('.venue_evaluation').find('.non-exists-question').attr('aria-hidden', 'false');
      }else{
        // hide the questions
        $(this).closest('.venue_evaluation').find('.non-exists-question').attr('aria-hidden', 'true');
      }
      // reset the values
      $(this).closest('.venue_evaluation').find('.non-exists-question input[type="radio"]').prop('checked', false);
      $(this).closest('.venue_evaluation').find('.non-exists-question input[type="text"]').val('').attr('aria-hidden', 'true');
    });

    // if radio button with evidence is selected, show the text box to get the evidence
    $('form.place div.venue_evaluation div.question-with-evidence input[type="radio"]').change(function(){
      show_question_evidence(this);
    });

    // if any fields are already marked, show evidence if necessary 
    $('form.place div.venue_evaluation div.question-with-evidence input[type="radio"]:checked').each(function(){
      show_question_evidence(this);
    });
    
    // when click on question category navigation, show the appropriate section
    $('ul.question_categories li a').click(function(){
      // unmark all links as active
      $('ul.question_categories li a').removeClass('active');
      // mark this link as active
      $('ul.question_categories li a[data-id="' + $(this).data('id') + '"]').addClass('active');

      // turn off all questions
      $('#question_category_lists .question_category').addClass('accessibly-hidden');
      // turn on the correct questions
      $('#question_category_lists .question_category[data-id="' + $(this).data('id') + '"]').removeClass('accessibly-hidden').focus();
      
      // make sure window is at the top
      $(window).scrollTop(0);
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

      $('#place_carousel').carousel();
  }
  


});
