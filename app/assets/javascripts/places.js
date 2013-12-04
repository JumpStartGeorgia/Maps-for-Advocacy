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
  
  if (gon.show_map){
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
});
