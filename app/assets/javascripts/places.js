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

    // if lat/lon and address already exist, show marker
    if ($('form.place input#place_lat').length > 0 && $('form.place input#place_lat').val() != '' &&
        $('form.place input#place_lon').length > 0 && $('form.place input#place_lat').val() != '' && 
        $('form.place input#place_place_translations_attributes_0_address').length > 0 && $('form.place input#place_place_translations_attributes_0_address').val() != ''){
      
      create_map_marker($('form.place input#place_lat').val(), 
                        $('form.place input#place_lon').val(), 
                        $('form.place input#place_place_translations_attributes_0_address').val());
      
    }
  }
  
  /*************************************************/
  /* javascript for place form */
  if (gon.show_place_form){
    // venue select box
    $('form.place #place_venue_id').select2({width:'element', allowClear:true});
    // when venu changes, update gon variable that is used to search for similar venues nearby
    $('form.place #place_venue_id').change(function(){
      gon.near_venue_id = $(this).val();
    });

    // as enter name, update hidden fields
    $('form.place #place_name').change(function(){
      var name = $(this).val();
      $('form.place input.place_form_name_translation').val($(this).val());
    })
    .keyup( function () {
      // fire the above change event after every letter
      $(this).change();
    });


    // if the user is using a browser that supports geolocation
    // use the current users coordinates
    if (gon.edit_place_form){
      load_place_form_map([gon.lat, gon.lon]);
      create_map_marker(gon.lat, gon.lon, null, true);
    }else if (navigator.geolocation){
      console.log('user can use geolocation');
      // not catching any errors for if there are some, the var coords will not change and that is ok
      navigator.geolocation.getCurrentPosition(get_user_coordinates, get_geolocation_error, {timeout:3000});
    } else{
      load_place_form_map();
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
      
      // after enter buliding number, add it to the beginning of the address
      $('input.builder_number').focusout(function(){
        var val = '';
        if ($(this).val() != ''){
          val = $(this).val() + ' ';
        }
        $('input.place_address').each(function(){
          $(this).val(val + $(this).data('original'));
        });
      });
    }
  }
/*  
  
  // show name for place form 
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

    $('form.place #place_url').change(function(){
      var name = $(this).val();
      var url = updateQueryStringParameter($('#place_name_next').attr('href'), 'url', name);

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
  
  // show map for place form
  if (gon.show_place_form_map){

  }
*/
  
  /*************************************************/
  /* show map for place show */
  if (gon.show_place_map){
      map = L.map(gon.map_id).setView([gon.lat, gon.lon], gon.zoom);
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
		  map.attributionControl = false;
		  map.zoomControl = true;
		
      marker = L.marker([gon.lat, gon.lon], {icon: L.icon(default_leaflet_icon_options)}).addTo(map);

      // show popup
      if (gon.marker_popup){
        marker.bindPopup(gon.marker_popup).openPopup();
      }

      $('#place_carousel').carousel();
  }
  
  /*************************************************/
  /* filters for the place images */
  $('#place-image-grid #place-image-filter #filter_image_evaluation').select2({width:'element', allowClear:true});
  $('#place-image-grid #place-image-filter #filter_image_type').select2({width:'element', allowClear:true});
  $('#place-image-grid #place-image-filter #filter_image_question').select2({width:'element', allowClear:true});
  /* when filters change, update images to show matches */
  function process_place_image_filter(){
    // first turn off all images and no image message
    $('#place-image-grid .place-image-grid-item a.place-image-link').removeClass('active').removeAttr('rel');
    $('#place-image-grid #place-image-grid-no-match').hide();
    // get filter values
    var filter_eval = $('#place-image-grid #place-image-filter #filter_image_evaluation').val();
    var filter_type = $('#place-image-grid #place-image-filter #filter_image_type').val();
    var filter_question = $('#place-image-grid #place-image-filter #filter_image_question').val();

    var filter = ''
    // build filter query
    if (filter_eval != ''){
      filter += '[data-certified="' + filter_eval + '"]';
    }
    if (filter_type != ''){
      filter += '[data-type="' + filter_type + '"]';
    }
    if (filter_question != ''){
      filter += '[data-question="' + filter_question + '"]';
    }
    
    // turn on appropriate images
    $('#place-image-grid .place-image-grid-item a.place-image-link' + filter).addClass('active').attr('rel', 'gallery');
  
    // if no images are showing, show no match message
    if ($('#place-image-grid .place-image-grid-item a.place-image-link[rel="gallery"]').length == 0){
      $('#place-image-grid #place-image-grid-no-match').fadeIn();
    }
  }
  // when filter changes, update the images
  $('#place-image-grid #place-image-filter #filter_image_evaluation, #place-image-grid #place-image-filter #filter_image_type, #place-image-grid #place-image-filter #filter_image_question').change(function(){
    process_place_image_filter();
  });  

  /*************************************************/
  /* when tabs change, update filters to match tabs */
  // update evaluation filter to match
  $('#evaluation-certified-tabs li a').click(function(){
    $('#place-image-grid #place-image-filter #filter_image_evaluation option[value="' + $(this).data('filter') + '"]').prop('selected', true).trigger("change");
    // turn off type filter
    $('#place-image-grid #place-image-filter #filter_image_type').val('').trigger("change");
  });
  // update type filter to match
  $('.evaluation-disability-tabs li a').click(function(){
    // - if eval filter is not selected, select the correct one
    if ($('#place-image-grid #place-image-filter #filter_image_evaluation').val() == ''){
      var eval_tab = $('#evaluation-certified-tabs li.active a');
      $('#place-image-grid #place-image-filter #filter_image_evaluation option[value="' + $(eval_tab).data('filter') + '"]').prop('selected', true).trigger("change");
    }
    
    $('#place-image-grid #place-image-filter #filter_image_type option[value="' + $(this).data('filter') + '"]').prop('selected', true).trigger("change");
  });

  /*************************************************/
  /* turn on fancybox for image slideshow on places page */
  $(".place-image-fancybox").fancybox({
    beforeLoad: function() {
      this.title = $(this.element).find('+ div.caption-text').html();
    },
    helpers:  {
      title : {
        type : 'outside'
      }
    }
  });

  /*************************************************/
  /* turn on fancybox for image slideshow on places page */
  $('#place-image-grid .place-image-grid-item a').tipsy({gravity: 's', fade: true, opacity: 0.9, html: true, title: 'formatted-title'});


});
