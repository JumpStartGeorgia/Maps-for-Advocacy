var map, marker, map_type, near_markers;
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
    // remove map markers
    if (marker != undefined){
      map.removeLayer(marker);  
    }
    if (near_markers != undefined && near_markers.length > 0){
      for(var i=0;i<near_markers.length;i++){
        map.removeLayer(near_markers[i]);  
      }
      near_markers = [];
    }

    if (map_type == 'settings'){
      $('#place_map_next').attr('href', updateQueryStringParameter($('#place_map_next').attr('href'), 'lat', ''));
      $('#place_map_next').attr('href', updateQueryStringParameter($('#place_map_next').attr('href'), 'lon', ''));
      $('#place_map_next').attr('href', updateQueryStringParameter($('#place_map_next').attr('href'), 'address', ''));

      // hide the button
      $('#place_map_next').attr('aria-hidden', 'true');
      $('#place_map_remove').attr('aria-hidden', 'true');
    }else{
      // reset form fields
      $('input#place_lat').val('');
      $('input#place_lon').val('');
      $('input.place_address').val('');

      // hide submit button
      $('#address-search-results #submit-button').attr('aria-hidden', 'true');
    }
    
    // hide previous messages
    $('#address-search-results > div').attr('aria-hidden', 'true');
    
        
  }

  /* update button coordinates */
  function update_link_parameters(coords, address){
    var lat = coords.lat;
    var lng = coords.lng;

    if (map_type == 'settings'){
        // update the url
        $('#place_map_next').attr('href', updateQueryStringParameter($('#place_map_next').attr('href'), 'lat', lat.toString()));
        $('#place_map_next').attr('href', updateQueryStringParameter($('#place_map_next').attr('href'), 'lon', lng.toString()));
        $('#place_map_next').attr('href', updateQueryStringParameter($('#place_map_next').attr('href'), 'address', address));

        // show the button
        $('#place_map_next').attr('aria-hidden', 'false');
        $('#place_map_remove').attr('aria-hidden', 'false');
    
    }else{
      // set form fields
      $('input#place_lat').val(lat.toString());
      $('input#place_lon').val(lng.toString());
      $('input.place_address').val(address);
      
      // show submit button
      $('#address-search-results #submit-button').attr('aria-hidden', 'false');
    }
  }

  /* show markers for places that were found near the address search result */
  function create_places_near_markers(places_near){
    if (places_near != undefined && places_near.length > 0){
      near_markers = [];
      var near_marker;
      var near_options = jQuery.extend({}, default_leaflet_icon_options);
      near_options['iconUrl'] = '/assets/marker-icon-red.png';         
      for (var i=0;i < places_near.length;i++){
        near_marker = L.marker([places_near[i].lat, places_near[i].lon], {icon: L.icon(near_options)}).addTo(map);
        near_marker.bindPopup(places_near[i].popup);
        near_markers.push(near_marker);
      }
    
    }
  }

  /* add map marker */
  function create_map_marker(lat, lon, address, perform_address_search){
    if (perform_address_search == undefined){
      perform_address_search = false;
    }
    
    var latlng = new L.LatLng(lat, lon);
    map.setView(latlng, gon.zoom);						
    marker = L.marker(latlng, {icon: L.icon(default_leaflet_icon_options)}).addTo(map);
    marker.dragging.enable();
    update_link_parameters(latlng, address);

    if (perform_address_search){
      // get the address
      var d = {lat: lat, lon: lon};
      if (gon.near_venue_id != undefined){
        d['near_venue_id'] = gon.near_venue_id;
      }
      $.post(gon.address_search_path,d,function(data){								
	      show_address_search_results(data.matches, latlng);												
        create_places_near_markers(data.places_near);	      
      });
    }
    
    marker.on("dragend",function(e){
      var latlng = e.target.getLatLng();
      update_link_parameters(latlng);

      // get the address
      var d = {lat: latlng.lat, lon: latlng.lng};
      if (gon.near_venue_id != undefined){
        d['near_venue_id'] = gon.near_venue_id;
      }
      $.post(gon.address_search_path,d,function(data){								
	      show_address_search_results(data.matches, latlng);												
        create_places_near_markers(data.places_near);	      
      });
    });
  }

  /* show results of address search */
  function show_address_search_results(data, marker_coords){
    // tell screen to not announce changes yet
    $('#address-search-results').attr('aria-busy', 'true');
    var lat, lon, address;
    
    if (data.length > 0){
      lat = data[0].coordinates[0];
      lon = data[0].coordinates[1];
      address = data[0].address;
    }
    
    if (marker_coords != undefined){
      lat = marker_coords.lat;
      lon = marker_coords.lng;
    }
    
    // reset the map
    reset_map();
    
    if (data.length == 0){
      $('#address-search-results #address-search-fail').attr('aria-hidden', 'false');
    }else if (data.length == 1){
      $('#address-search-results #address-search-1-match .placeholder').html(address);
      $('#address-search-results #address-search-1-match').attr('aria-hidden', 'false');

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

        html += '<li><input type="radio" name="address" value="' + i + '" id="address_' + i + '" ';
        // select the first one by default
        if (i == 0){
          html += 'checked="checked"';
        }
        html += 'data-lat="' + lat + '" data-lon="' + lon + '" data-address="' + address + '"><label for="address_' + i + '">' + address + '</label></li>';
      }
      html += '</ul>';
      $('#address-search-results #address-search-multiple-match .placeholder').html(html);
      $('#address-search-results #address-search-multiple-match').attr('aria-hidden', 'false');

      // create marker for item that is selected by default
      var first_marker = $('#address-search-results div input[type="radio"]:checked');
      create_map_marker($(first_marker).data('lat'), $(first_marker).data('lon'), $(first_marker).data('address'));


      $('#address-search-results div input[type="radio"]').on('change', function(){
        if (marker != undefined){
          map.removeLayer(marker);  
        }

        // create marker
        create_map_marker($(this).data('lat'), $(this).data('lon'), $(this).data('address'));
      });
    }

    // tell screen reader that it is ok to announce changes
    $('#address-search-results').attr('aria-busy', 'false');
    $('#address-search-results a#address-search-results').focus();
  }
  

  function search_for_address(){
    reset_map();

    var address = $('input#address-search').val();
    if (address.length == 0){
      // show msg
      $('#address-search-results #address-search-fail').attr('aria-hidden', 'false');
      $('#address-search-results a#address-search-results').focus();
    }else
    {
      var d = {address:address};
      if (gon.near_venue_id != undefined){
        d['near_venue_id'] = gon.near_venue_id;
      }
      $.post(gon.address_search_path,d,function(data){								
	      show_address_search_results(data.matches);												
        create_places_near_markers(data.places_near);	      
      });
    }
  }


