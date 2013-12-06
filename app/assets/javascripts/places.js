var map, marker;
$(document).ready(function(){
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

  function set_map_marker_coordinates(coords){
    var lat = coords.lat;
    var lng = coords.lng;

    var url = $('form.place #place_map_next').attr('href');
    url = updateQueryStringParameter(url, 'lat', lat.toString());
    url = updateQueryStringParameter(url, 'lon', lng.toString());
    
    $('form.place #place_map_next').attr('href', url).css('display', 'inline');
  }

  function create_map_marker(lat, lon){
    var latlng = new L.LatLng(lat, lon);
    map.setView(latlng, gon.zoom);						
    marker.setLatLng(latlng).addTo(map);
    marker.dragging.enable();
    set_map_marker_coordinates(latlng);

    marker.on("dragend",function(e){
      set_map_marker_coordinates(e.target.getLatLng());
    });
  }

  function show_address_search_results(data){
    console.log('coords = ' + data + '; length = ' + data.length);
    // hide previous messages
    $('form.place #address-search-results > div').fadeOut(100);
    if (data.length == 0){
      $('form.place #address-search-results #address-search-fail').fadeIn();
    }else if (data.length == 1){
      console.log('results has 1 match');
      $('form.place #address-search-results #address-search-1-match .placeholder').html(data[0].address);
      $('form.place #address-search-results #address-search-1-match').fadeIn();

      create_map_marker(data[0].coordinates[0], data[0].coordinates[1]);

    }else {
      // create list of matches so user can select
      // when select option, show map marker for it
      console.log('found ' + data.length + ' matches');			    
      var html = '<ul>';
      for (var i = 0; i<data.length; i++){
        html += '<li><label for="address_' + i + '"><input type="radio" name="address" value="' + i + '" id="address_' + i + '" ';
        // select the first one by default
        if (i == 0){
          html += 'checked="checked"' ;
        }
        html += 'data-lat="' + data[i].coordinates[0] + '" data-lon="' + data[i].coordinates[1] + '">' + data[i].address + '</label></li>';
      }
      html += '</ul>';
      $('form.place #address-search-results #address-search-multiple-match .placeholder').html(html);
      $('form.place #address-search-results #address-search-multiple-match').fadeIn();

      // create marker for item that is selected by default
      var first_marker = $('form.place #address-search-results div input[type="radio"]:checked');
      create_map_marker($(first_marker).data('lat'), $(first_marker).data('lon'));


      $('form.place #address-search-results div input[type="radio"]').on('change', function(){
        console.log('radio button selected');
        // create marker
        create_map_marker($(this).data('lat'), $(this).data('lon'));
      });

    }
  }
  
  
  /* show map for place form */
  if (gon.show_place_form_map){
      map = L.map(gon.map_id).setView([gon.lat, gon.lon], gon.zoom);
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
		  map.attributionControl = false;
		  map.zoomControl = true;
		
      marker = L.marker();

      marker.on("dragend",function(e){
        set_map_marker_coordinates(e.target.getLatLng());
			});
			
      function onMapClick(e) {
        marker.setLatLng(e.latlng).addTo(map);
        marker.dragging.enable();
        set_map_marker_coordinates(e.latlng);

        // get the address
	      $.post(gon.address_search_path,{lat: e.latlng.lat, lon: e.latlng.lng}, function(data){								
		      show_address_search_results(data);												
        });
      }

      map.on('click', onMapClick);  
  }
  
  /* show map for place show */
  if (gon.show_place_map){
      map = L.map(gon.map_id).setView([gon.lat, gon.lon], gon.zoom);
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
		  map.attributionControl = false;
		  map.zoomControl = true;
		
      marker = L.marker([gon.lat, gon.lon]).addTo(map);
  }
  
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


  /* perform an address search */
  if (gon.address_search_path){
    $('form.place #submit-address-search').click(function(){
      console.log('link clicked!');

      map.removeLayer(marker);

      var address = $('form.place input#address-search').val();
      if (address.length == 0){
        console.log('no address entered');        
        // hide previous messages
        $('form.place #address-search-results > div').fadeOut(100);
        // show msg
        $('form.place #address-search-results #address-search-fail').fadeIn();        
      }else
      {
        console.log('calling post!');
	      $.post(gon.address_search_path,{address:address},function(data){								
		      show_address_search_results(data);												
	      });
      }
	
		  return false;
    });
  }

});
