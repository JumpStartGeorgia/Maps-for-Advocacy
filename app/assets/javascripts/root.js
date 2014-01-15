var map;
$(document).ready(function(){

  /* use the select2 library on the frontpage */
  if (gon.frontpage_filters){
    $('#filter_disability').select2({width:'element'});
    $('#filter_venue').select2({width:'element'});
    $('#filter_district').select2({width:'element'});
  
  }

  /* show map for front place form */
  if (gon.show_frontpage_map){

    function resize_frontpage_map(){
	    $('#front-page #map').height($(window).height() - $('.popup').height() - $('footer').height() - 90);
    }


    // stretch map to fit available height
    resize_frontpage_map();
		$(window).bind('resize', resize_frontpage_map);
    
	
    // show all markers
    // if markers are present, the fitBounds will determine the zoom level
    // otherwise, set initial zoom level
    if (gon.markers && gon.markers.length > 0){
      // load map
      map = L.map(gon.map_id, {center: [gon.lat_front_page, gon.lon_front_page]});
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
	    map.attributionControl = false;
	    map.zoomControl = true;

      var marker;
      var coords = [];
      for (var i=0;i < gon.markers.length;i++){
        marker = L.marker([gon.markers[i].lat, gon.markers[i].lon]).addTo(map);
        marker.bindPopup(gon.markers[i].popup);
        coords.push([gon.markers[i].lat, gon.markers[i].lon]);
      }

			// set bounds on markers
			map.fitBounds(new L.LatLngBounds(coords));

      // turn on the carousel if needed
      if (gon.map_carousel_id_text && gon.map_carousel_ids.length > 0){
        $('#' + map_carousel_id_text + map_carousel_id_text).carousel();
      }

    }else{
      // load map
      map = L.map(gon.map_id, {center: [gon.lat_front_page, gon.lon_front_page], zoom: gon.zoom_front_page});
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
	    map.attributionControl = false;
	    map.zoomControl = true;
    }
    
  }
  

});
