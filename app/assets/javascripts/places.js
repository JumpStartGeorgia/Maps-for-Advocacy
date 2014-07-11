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
    // turn venue list into menu
    $('form.place ul#venues').menu();
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
  


});
