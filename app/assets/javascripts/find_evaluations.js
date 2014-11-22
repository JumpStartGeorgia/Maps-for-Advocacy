var map;
var landing_page_markers = {};
$(document).ready(function(){

  /* use the select2 library on the frontpage */
  if (gon.find_evaluations_filters){
    $('#filter_disability').select2({width:'element', allowClear:true});
    $('#filter_venue').select2({width:'element', allowClear:true});
    $('#filter_district').select2({width:'element', allowClear:true});

    $('#btn_search').on('click', function(e){
      e.preventDefault();
    
      var url = window.location.href;
      url = UpdateQueryString(url, 'place_search', $('#filter_place_search').val());
      url = UpdateQueryString(url, 'address_search', $('#filter_address_search').val());
      url = UpdateQueryString(url, 'venue_category_id', $('#filter_venue').val());
      // if no district selected then default to '0' for all
      var val = $('#filter_district').val();
      url = UpdateQueryString(url, 'district_id', val == '' ? '0' : val);
      // make sure value is 1 or 0
      var val = $('#filter_evaluations:checked').length == 0 ? '0' : '1';
      url = UpdateQueryString(url, 'places_with_evaluation', val);
      url = UpdateQueryString(url, 'eval_type_id', $('#filter_disability').val());

      document.location = url;
    });

    $('#filter_evaluations').on('change', function(e){
      $('#disability_filter').slideToggle();
      $('#filter_disability').select2({width:'element', allowClear:true});
    });

/*    
    $('#filter_place_search').on('change', function(e){
      document.location = UpdateQueryString(null, 'place_search', $(this).val());
    });
    $('#filter_address_search').on('change', function(e){
      document.location = UpdateQueryString(null, 'address_search', $(this).val());
    });
    $('#filter_venue').on('change', function(e){
      document.location = UpdateQueryString(null, 'venue_category_id', $(this).val());
    });
    $('#filter_district').on('change', function(e){
      // if no value selected then default to '0' for all
      var val = $(this).val();
      document.location = UpdateQueryString(null, 'district_id', val == '' ? '0' : val);
    });
    $('#filter_evaluations').on('change', function(e){
      var val = $(this + ':checked').length == 0 ? '0' : '1';
      document.location = UpdateQueryString(null, 'places_with_evaluation', val);
    });
    $('#filter_disability').on('change', function(e){
      document.location = UpdateQueryString(null, 'eval_type_id', $(this).val());
    });
*/
    
  
  }

  /* show map for find evaluation page */
  if (gon.show_find_evaluations_map){

    function resize_frontpage_map(){
	    $('#find-evaluations #map').height($(window).height() - $('.popup').height() - $('footer').height() - 90);

      var heights = [];
      heights.push($('#find-evaluations #search-container #search').height());
      heights.push($('#find-evaluations #search-container #search_results').height());
      // update heights to max height of visible detail charts
      $('#find-evaluations #map').height(Math.max.apply(Math, heights));
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
        marker = L.marker([gon.markers[i].lat, gon.markers[i].lon], {icon: L.icon(default_leaflet_icon_options)}).addTo(map);
        marker.bindPopup(gon.markers[i].popup);
        // record the marker so can highlight when user hovers over search results list item
        landing_page_markers[gon.markers[i].id] = marker;
        // record coords so can determine bounds for map
        coords.push([gon.markers[i].lat, gon.markers[i].lon]);
      }

			// set bounds on markers
			map.fitBounds(new L.LatLngBounds(coords));
/*
      // turn on the carousel if needed
      if (gon.map_carousel_id_text && gon.map_carousel_ids.length > 0){
        $('#' + map_carousel_id_text + map_carousel_id_text).carousel();
      }
*/

      // when user hovers over search result item, highlight it on the map
      $('.place-item').hover(function(){
        // when mouse over
        // find the marker 
        var m = landing_page_markers[$(this).data('id')];
        // set new icon
        m.setIcon(L.icon(red_leaflet_icon_options));
      },function(){
        // when mouse out
        var m = landing_page_markers[$(this).data('id')];
        // reset icon
        m.setIcon(L.icon(default_leaflet_icon_options));
      });
      

    }else{
      // load map
      map = L.map(gon.map_id, {center: [gon.lat_front_page, gon.lon_front_page], zoom: gon.zoom_front_page});
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
	    map.attributionControl = false;
	    map.zoomControl = true;
    }
    
  }
  

});
