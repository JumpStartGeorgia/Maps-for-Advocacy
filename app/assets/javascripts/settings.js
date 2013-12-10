$(document).ready(function(){
  /*************************************************/
  /* show map for user settings page */
  if (gon.show_settings_map){
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
  }
  


});
