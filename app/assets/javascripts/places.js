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
  
  /* show map for place form */
  if (gon.show_place_form_map){
      var map = L.map(gon.map_id).setView([gon.lat, gon.lon], gon.zoom);
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
		  map.attributionControl = false;
		  map.zoomControl = true;
		
      var marker = L.marker();

      marker.on("dragend",function(e){
        set_map_marker_coordinates(e.target.getLatLng());
			});
			
      function onMapClick(e) {
          marker.setLatLng(e.latlng).addTo(map);
          marker.dragging.enable();
          set_map_marker_coordinates(e.latlng);
      }

      map.on('click', onMapClick);  
  }
  
  /* show map for place show */
  if (gon.show_place_map){
      var map = L.map(gon.map_id).setView([gon.lat, gon.lon], gon.zoom);
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
		  map.attributionControl = false;
		  map.zoomControl = true;
		
      var marker = L.marker([gon.lat, gon.lon]).addTo(map);
  }
  
  /* show the evidence text fields as need */
  if (gon.show_evaluation_form){
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

});
