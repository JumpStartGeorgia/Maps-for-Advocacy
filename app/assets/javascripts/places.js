var map, marker;
$(document).ready(function(){
  /* update a query string value in a url */
  function updateQueryStringParameter(uri, key, value) {
    var re = new RegExp("([?|&])" + key + "=.*?(&|$)", "i");
    separator = uri.indexOf('?') !== -1 ? "&" : "?";
    if (uri.match(re)) {
      return uri.replace(re, '$1' + key + "=" + value + '$2');
    }
    else {
      return uri + separator + key + "=" + value;
    }
  }

  /* hide the next button, map markers and messages */
  function reset_map(){
    var url = $('form.place #place_map_next').attr('href');
    url = updateQueryStringParameter(url, 'lat', '');
    url = updateQueryStringParameter(url, 'lon', '');
    url = updateQueryStringParameter(url, 'address', '');
    
    // update button url and hide
    $('form.place #place_map_next').attr('href', url).attr('aria-hidden', 'true');
    
    // remove map markers
    if (marker != undefined){
      map.removeLayer(marker);  
    }
  
    // hide previous messages
    $('form.place #address-search-results > div').fadeOut(100);
  }

  /* update button coordinates */
  function update_link_parameters(coords, address){
    var url = $('form.place #place_map_next').attr('href');
    var lat = coords.lat;
    var lng = coords.lng;

    url = updateQueryStringParameter(url, 'lat', lat.toString());
    url = updateQueryStringParameter(url, 'lon', lng.toString());
    if (address != undefined && address != null){
      url = updateQueryStringParameter(url, 'address', encodeURIComponent(address));
    }
    
    $('form.place #place_map_next').attr('href', url).attr('aria-hidden', 'false');
  }

  /* add map marker */
  function create_map_marker(lat, lon, address, perform_address_search){
    if (perform_address_search == undefined){
      perform_address_search = false;
    }
    
    var latlng = new L.LatLng(lat, lon);
    map.setView(latlng, gon.zoom);						
    marker = L.marker(latlng).addTo(map);
    marker.dragging.enable();
    update_link_parameters(latlng, address);

    if (perform_address_search){
      // get the address
      $.post(gon.address_search_path,{lat: lat, lon: lon}, function(data){								
        show_address_search_results(data, latlng);												
      });
    }
    
    marker.on("dragend",function(e){
      var latlng = e.target.getLatLng();
      update_link_parameters(latlng);

      // get the address
      $.post(gon.address_search_path,{lat: latlng.lat, lon: latlng.lng}, function(data){								
	      show_address_search_results(data, latlng);												
      });
    });
  }

  /* show results of address search */
  function show_address_search_results(data, marker_coords){
    // tell screen to not announce changes yet
    $('form.place #address-search-results').attr('aria-busy', 'true');

    var lat = data[0].coordinates[0];
    var lon = data[0].coordinates[1];
    var address = data[0].address;
    
    if (marker_coords != undefined){
      lat = marker_coords.lat;
      lon = marker_coords.lng;
    }
    
    // reset the map
    reset_map();
    
    if (data.length == 0){
      $('form.place #address-search-results #address-search-fail').fadeIn();
    }else if (data.length == 1){
      $('form.place #address-search-results #address-search-1-match .placeholder').html(address);
      $('form.place #address-search-results #address-search-1-match').fadeIn();

      create_map_marker(lat, lon, address);

    }else {
      // create list of matches so user can select
      // when select option, show map marker for it
      var html = '<ul>';
      for (var i = 0; i<data.length; i++){
        if (marker_coords == undefined){
          lat = data[i].coordinates[0];
          lon = data[i].coordinates[1];
        }
        address = data[i].address;

        html += '<li><label for="address_' + i + '"><input type="radio" name="address" value="' + i + '" id="address_' + i + '" ';
        // select the first one by default
        if (i == 0){
          html += 'checked="checked"';
        }
        html += 'data-lat="' + lat + '" data-lon="' + lon + '" data-address="' + address + '">' + address + '</label></li>';
      }
      html += '</ul>';
      $('form.place #address-search-results #address-search-multiple-match .placeholder').html(html);
      $('form.place #address-search-results #address-search-multiple-match').fadeIn();

      // create marker for item that is selected by default
      var first_marker = $('form.place #address-search-results div input[type="radio"]:checked');
      create_map_marker($(first_marker).data('lat'), $(first_marker).data('lon'), $(first_marker).data('address'));


      $('form.place #address-search-results div input[type="radio"]').on('change', function(){
        if (marker != undefined){
          map.removeLayer(marker);  
        }

        // create marker
        create_map_marker($(this).data('lat'), $(this).data('lon'), $(this).data('address'));
      });

    }

    // tell screen reader that it is ok to announce changes
    $('form.place #address-search-results').attr('aria-busy', 'false');
  }
  
  /*************************************************/
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
  
    function search_for_address(){
      reset_map();

      var address = $('form.place input#address-search').val();
      if (address.length == 0){
        // show msg
        $('form.place #address-search-results #address-search-fail').fadeIn();        
      }else
      {
	      $.post(gon.address_search_path,{address:address},function(data){								
		      show_address_search_results(data);												
	      });
      }
    }

    /* if enter key is pressed do address search */
    $('form.place input#address-search').keypress(function(event){
	    var keycode = (event.keyCode ? event.keyCode : event.which);
	    if(keycode == '13'){
		    search_for_address();
        return false;
	    }
     
    });
      
    $('form.place #submit-address-search').click(function(){
      search_for_address();
		  return false;
    });
  }

  /*************************************************/
  /* actions for the evaluation form */
  if (gon.show_evaluation_form){
    /* show the evidence text fields as need */
    function show_question_evidence(ths){
      if ($(ths).is(':checked') && ($(ths).val() == '3' || $(ths).val() == '2') ) {
        $(ths).closest('tr').find('input[type="text"]').css('display', 'none');
        $(ths).closest('td').find('input[type="text"]').css('display', 'inline');
      } else{
        $(ths).closest('tr').find('input[type="text"]').css('display', 'none');
      }
    }
  
    $('form.place table.venue_evaluation tr.question-with-evidence td input[type="radio"]').change(function(){
      show_question_evidence(this);
    });

    /* if any vields are already marked, show evidence if necessary */  
    $('form.place table.venue_evaluation tr.question-with-evidence td input[type="radio"]:checked').each(function(){
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
  }
  


});
