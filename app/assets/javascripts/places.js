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
      var url = UpdateQueryString($('#place_name_next').attr('href'), 'name', name);

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
      var url = UpdateQueryString($('#place_name_next').attr('href'), 'url', name);

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
  
  if (gon.show_place_images){
    /*************************************************/
    /* filters for the place images */
    function resize_place_image_filters(){
      $('#place-image-grid #place-image-filter #filter_image_evaluation').select2({width:'element', allowClear:true});
      $('#place-image-grid #place-image-filter #filter_image_type').select2({width:'element', allowClear:true});
      $('#place-image-grid #place-image-filter #filter_image_question').select2({width:'element', allowClear:true});
    }

    $(window).bind('resize', resize_place_image_filters);
    resize_place_image_filters();

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
  }


  /*************************************************/
  /* place show page */
  function resize_place_eval_filters(){
    $('#filter_certified').select2({width:'element'});
    $('#filter_type').select2({width:'element'});
  }

  $(window).bind('resize', resize_place_eval_filters);
  resize_place_eval_filters();

  // turn off all blocks and show the appropriate one
  function show_place_summary_block(){
    // turn all off
    $('#place-summary-container .summary-block').addClass('accessibly-hidden');

    // get values of which to turn on
    var cert_value = $('#filter_certified').val();
    var type_value = $('#filter_type').val();
    // get names for selected items
    var cert_name = $('#filter_certified option:selected').data('name');
    var type_name = $('#filter_type option:selected').data('name');

    // show the correct header
    $('#place-summary-container > h3').html(cert_name + ': ' + type_name);
    // show the correct block
    $('#place-summary-container .summary-block[data-certified="' + cert_value + '"][data-type="' + type_value + '"]').removeClass('accessibly-hidden');
  }

  // when the certified status changes, update the type filter and the view
  $('#filter_certified').on('change', function(e){
    var val = $(this).val();
    var type_val = $('#filter_type').val();

    // turn off all selections
    $('#filter_type option').addClass('accessibly-hidden');

    if (val == 'true'){
      // certified
      $('#filter_type option[data-certified="true"]').removeClass('accessibly-hidden');
      // show the correct numbers
      $('#filter_type option[data-certified="true"]').each(function(){
        $(this).html($(this).data('name') + $(this).data('count-cert'));
      });

    }else{
      // public
      $('#filter_type option[data-public="true"]').removeClass('accessibly-hidden');
      // show the correct numbers
      $('#filter_type option[data-public="true"]').each(function(){
        $(this).html($(this).data('name') + $(this).data('count-public'));
      });
    }

    // if old type value is no longer visible, reset to all option
    if ($('#filter_type option[value="' + type_val + '"]').hasClass('accessibly-hidden')){
      // not visible, reset
      $('#filter_type').val('0');
    }

    // trigger a change event so the select value has updated count
    $('#filter_type').trigger('change');

    // show the correct summary
    show_place_summary_block();

    // update the place image filters
    $('#place-image-grid #place-image-filter #filter_image_evaluation option[value="' + val + '"]').prop('selected', true).trigger("change");
    // turn off type filter
    $('#place-image-grid #place-image-filter #filter_image_type').val('').trigger("change");

  });

  // when the type status changes, update the the view
  $('#filter_type').on('change', function(e){
    // show the correct summary
    show_place_summary_block();

    // update the place image filters
    // - if eval filter is not selected, select the correct one
    if ($('#place-image-grid #place-image-filter #filter_image_evaluation').val() == ''){
      $('#place-image-grid #place-image-filter #filter_image_evaluation option[value="' + $('#filter_certified').val() + '"]').prop('selected', true).trigger("change");
    }
    
    $('#place-image-grid #place-image-filter #filter_image_type option[value="' + $(this).val() + '"]').prop('selected', true).trigger("change");
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
