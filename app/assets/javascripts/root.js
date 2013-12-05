$(document).ready(function(){

  /* show map for front place form */
  if (gon.show_frontpage_map){

    function resize_frontpage_map(){
	    $('#front-page #map').height($(window).height() - $('.popup').height() - $('footer').height() - 90);
    }


    // stretch map to fit available height
    resize_frontpage_map();
		$(window).bind('resize', resize_frontpage_map);
    
    // load map
    var map = L.map(gon.map_id).setView([gon.lat_front_page, gon.lon_front_page], gon.zoom_front_page);
    L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
	  map.attributionControl = false;
	  map.zoomControl = true;
	
    // show all markers
    if (gon.markers && gon.markers.length > 0){
      var marker;
      var coords = [];
      for (var i=0;i < gon.markers.length;i++){
        marker = L.marker([gon.markers[i].lat, gon.markers[i].lon]).addTo(map);
        marker.bindPopup(gon.markers[i].popup);
        coords.push([gon.markers[i].lat, gon.markers[i].lon]);
      }
      
			// set bounds on markers
			map.fitBounds(new L.LatLngBounds(coords));
    }
  }
  

});
