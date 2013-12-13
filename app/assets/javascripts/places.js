$(document).ready(function(){
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

      // show popup
      if (gon.marker_popup){
        marker.bindPopup(gon.marker_popup).openPopup();
      }

  }
  


});
