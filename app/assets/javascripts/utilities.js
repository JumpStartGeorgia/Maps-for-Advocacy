var map, marker;
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
    var url = $('#place_map_next').attr('href');
    url = updateQueryStringParameter(url, 'lat', '');
    url = updateQueryStringParameter(url, 'lon', '');
    url = updateQueryStringParameter(url, 'address', '');
    
    // update button url and hide
    $('#place_map_next').attr('href', url).attr('aria-hidden', 'true');
    
    // remove map markers
    if (marker != undefined){
      map.removeLayer(marker);  
    }
  
    // hide previous messages
    $('#address-search-results > div').attr('aria-hidden', 'true');
  }

  /* update button coordinates */
  function update_link_parameters(coords, address){
    var url = $('#place_map_next').attr('href');
    var lat = coords.lat;
    var lng = coords.lng;

    url = updateQueryStringParameter(url, 'lat', lat.toString());
    url = updateQueryStringParameter(url, 'lon', lng.toString());
    if (address != undefined && address != null){
      url = updateQueryStringParameter(url, 'address', encodeURIComponent(address));
    }
    
    $('#place_map_next').attr('href', url).attr('aria-hidden', 'false');
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
//      $('#address-search-results #address-search-fail').fadeIn();
      $('#address-search-results #address-search-fail').attr('aria-hidden', 'false');
    }else if (data.length == 1){
      $('#address-search-results #address-search-1-match .placeholder').html(address);
//      $('#address-search-results #address-search-1-match').fadeIn();
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
//      $('#address-search-results #address-search-multiple-match').fadeIn();
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
  }
  

  function search_for_address(){
    reset_map();

    var address = $('input#address-search').val();
    if (address.length == 0){
      // show msg
//      $('#address-search-results #address-search-fail').fadeIn();        
      $('#address-search-results #address-search-fail').attr('aria-hidden', 'false');
    }else
    {
      $.post(gon.address_search_path,{address:address},function(data){								
	      show_address_search_results(data);												
      });
    }
  }


