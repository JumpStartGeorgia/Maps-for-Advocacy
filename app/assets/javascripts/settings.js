$(document).ready(function(){
  /*************************************************/
  /* show map for user settings page */
  if (gon.show_settings_map){
      // used in update_link_parameters in utilities.js to properly set the link values
      map_type = 'settings';
      
      map = L.map(gon.map_id).setView([gon.lat, gon.lon], gon.zoom);
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
		  map.attributionControl = false;
		  map.zoomControl = true;
		
      create_map_marker(gon.lat, gon.lon, null, true);

      function onMapClick(e){
        reset_map();
        create_map_marker(e.latlng.lat, e.latlng.lng, null, true);
      }
      
      map.on('click', onMapClick);  


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


  }
  


});
