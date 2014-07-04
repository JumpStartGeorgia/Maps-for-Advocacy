$(document).ready(function(){
  // get the user coordinates
  function get_user_coordinates(position){
    load_place_form_map([position.coords.latitude, position.coords.longitude]);
  }

  function get_geolocation_error(error) {
    var errors = { 
      1: 'Permission denied',
      2: 'Position unavailable',
      3: 'Request timeout'
    };
    console.log("geo location error: " + errors[error.code]);
    load_place_form_map();
  }

  function load_place_form_map(coords){
    console.log("- coords " + coords);
    if (coords == undefined){
      console.log("- coords not passed in, using default gon coords");
      coords = [gon.lat, gon.lon];
    }
    
    map = L.map(gon.map_id).setView(coords, gon.zoom);
    L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
	  map.attributionControl = false;
	  map.zoomControl = true;
	
    function onMapClick(e){
      reset_map();
      create_map_marker(e.latlng.lat, e.latlng.lng, null, true);
    }
    
    map.on('click', onMapClick);  
  }
  
  // show question evidence validation message and reset fields if necesary
  function show_question_evidence_message(message, alert_type, obj_parent, obj_evidence, reset_values){
    if (reset_values == undefined || reset_values == null){
      reset_values = false;
    }
    
    // show the message
    $(obj_evidence).find('.evidence-message-container').removeClass('alert-success alert-error accessibly-hidden').addClass(alert_type);
    $(obj_evidence).find('.evidence-message').html(message);
    
    // reset values if needed
    if (reset_values){
      $(obj_evidence).find('input[type="text"]:first').focus();
      $(obj_parent).find('input[type="radio"]').prop('checked', false);
    }
  }

  /*************************************************/
  /* venue filter on place form */
  if (gon.place_form_venue_filter){
    $('ul#venue_categories li a').click(function(){
      // unmark all links as active
      $('ul#venue_categories li a').removeClass('active');
      // mark this link as active
      $(this).addClass('active');

      // turn off all lists
      $('#venue_category_lists .venue_category').addClass('accessibly-hidden');
      // turn on the correct list
      $('#venue_category_lists .venue_category[data-id="' + $(this).data('id') + '"]').removeClass('accessibly-hidden').focus();
     
      // make sure window is at the top
      $(window).scrollTop(0);
    });
  }
  
  
  /* show name for place form */
  if (gon.show_place_name_form){
    $('form.place #place_name').change(function(){
      var name = $(this).val();
      var url = updateQueryStringParameter($('#place_name_next').attr('href'), 'name', name);

      if (name.length == 0){
        // hide the next button
        $('#place_name_next').attr('href', url).attr('aria-hidden', 'true');
      }else {
        // show the next button
        $('#place_name_next').attr('href', url).attr('aria-hidden', 'false');
      }
    })
    .keyup( function () {
      // fire the above change event after every letter
      $(this).change();
    })
    .keypress(function(event){
	    var keycode = (event.keyCode ? event.keyCode : event.which);
	    if(keycode == '13'){
        return false;
	    }
    });

  }  
  
  
  /* show map for place form */
  if (gon.show_place_form_map){
      // if the user is using a browser that supports geolocation
      // use the current users coordinates
      if (navigator.geolocation){
        console.log('user can use geolocation');
        // not catching any errors for if there are some, the var coords will not change and that is ok
        navigator.geolocation.getCurrentPosition(get_user_coordinates, get_geolocation_error);
      } else{
        load_place_form_map();
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
      
      // after enter buliding number, add it to the beginning of the address
      $('input.builder_number').focusout(function(){
        var val = '';
        if ($(this).val() != ''){
          val = $(this).val() + ' ';
        }
        $('input.place_address').val(val + $('#address-search-results div input[type="radio"]:checked').data('address'));
      });
    }
  }
  

  /*************************************************/
  /* actions for the evaluation form */
  if (gon.show_evaluation_form){

    // when click on question category navigation, show the appropriate section
    $('ul.question_categories li a').click(function(){
      // unmark all links as active
      $('ul.question_categories li a').removeClass('active');
      // mark this link as active
      $('ul.question_categories li a[data-id="' + $(this).data('id') + '"]').addClass('active');

      // turn off all questions
      $('#question_category_lists .question_category').addClass('accessibly-hidden');
      // turn on the correct questions
      $('#question_category_lists .question_category[data-id="' + $(this).data('id') + '"]').removeClass('accessibly-hidden').focus();
      
      // make sure window is at the top
      $(window).scrollTop(0);
    });
    

    // show the submit button if at least one item is selected
    $('form.place div.venue_evaluation input[type="radio"]').change(function(){
      if ($('form.place div.venue_evaluation input[type="radio"]:checked').length == 0){
        $('form.place #submit-button').addClass('accessibly-hidden');
      }else{
        $('form.place #submit-button').removeClass('accessibly-hidden');
      }
    });
    
    // if exists question is marked as yes, show the rest of the questions
    $('form.place div.venue_evaluation div.exists-question input[type="radio"]').change(function(){
      // get exists id 
      var exists_id = $(this).closest('.venue_evaluation_question').data('exists-id');
      if (gon.answer_yes == $(this).val()){
        // show the questions
        $(this).closest('.venue_evaluation').find('.venue_evaluation_question[data-exists-parent-id="' + exists_id + '"]').each(function(){
          $(this).attr('aria-hidden', 'false')

          // reset the values
          $(this).find('input[type="radio"]').prop('checked', false);
          $(this).find('input[type="text"]').val('');
        });
      }else{
        // hide the questions
        $(this).closest('.venue_evaluation').find('.venue_evaluation_question[data-exists-parent-id="' + exists_id + '"]').each(function(){
          $(this).attr('aria-hidden', 'true')

          // reset the values
          $(this).find('input[type="radio"]').prop('checked', false);
          $(this).find('input[type="text"]').val('');
        });
      }
    });
    
    // if press enter while in evidence field, trigger validate button
    $('form.place div.venue_evaluation .evidence .question-evidence').keypress(function(event){
      var keycode = (event.keyCode ? event.keyCode : event.which);
      if(keycode == '13'){
        $(this).closest('.evidence').find('a.process_evidence').trigger('click');
        return false;
      }
     
    });    

    // process measurements and see if valid
    $('form.place div.venue_evaluation .evidence a.process_evidence').click(function(e){
      e.preventDefault();

      var obj_parent = $(this).parent().parent();
      var obj_evidence = $(this).parent();
      var val_eq = $(obj_evidence).data('val-eq').toString();
      var val_eq_units = $(obj_evidence).data('val-eq-units');
      var is_angle = $(obj_evidence).data('is-angle');
      var raw_evidence = [];
      var evidence = [];
      var units = [];

      $(this).parent().find('.evidence-message-container').attr('aria-busy', 'true');

      // get evidence and unit values
      $(obj_evidence).find('input[type="text"]').each(function(){
        raw_evidence.push($(this).val().trim());
        evidence.push(/[0-9.]+/g.exec($(this).val().trim())); // number, no units
        units.push($(this).val().replace(/[^a-zA-Z]+/g, '').trim()); // text only
      });
      
      // if no evidence entered, show error
      // - if this is an angle measurement, either the first 2 evidences must be provided or the last one
      var has_evidence = true;
      var has_angle_evidence = true;
      if (is_angle){
        if (!((evidence[0] != null && evidence[0].length > 0 && evidence[1] != null && evidence[1].length > 0 && (evidence[2] == null || evidence[2].length == 0)) || 
              (evidence[2] != null && evidence[2].length > 0 && (evidence[0] == null || evidence[0].length == 0) && (evidence[0] == null || evidence[0].length == 0)))) {
          has_angle_evidence = false;
        }
      }else{
        for(var i=0; i<evidence.length;i++){
          if (evidence[i] == null || evidence[i].length == 0){
            has_evidence = false;
            break;
          }
        }
      }
      if (!has_evidence){
        show_question_evidence_message(gon.no_evidence_entered, 'alert-error', obj_parent, obj_evidence, true)
        return
      }else if (!has_angle_evidence){
        show_question_evidence_message(gon.no_evidence_entered_angle, 'alert-error', obj_parent, obj_evidence, true)
        return
      }
      
      // if units not match or not provided, show error
      var has_units = true;
      var units_match = true;
      var units_angle_match = true;
      if (is_angle){
        // if height/depth provided, make sure they are in the same units
        if (units[0].toLowerCase() != units[1].toLowerCase()){
          units_angle_match = false;
        }
      }else {
        for(var i=0; i<units.length;i++){
          if (units[i].length == 0){
            has_units = false;
            break;
          }else if (units[i].toLowerCase() != val_eq_units){
            units_match = false;
            break;
          }
        }
      }
      if (!has_units){
        show_question_evidence_message(gon.no_units_entered, 'alert-error', obj_parent, obj_evidence, true)
        return
      }else if (!units_match){
        show_question_evidence_message(gon.units_not_match.replace('[unit]', val_eq_units), 'alert-error', obj_parent, obj_evidence, true)
        return
      }else if (!units_angle_match){
        show_question_evidence_message(gon.units_not_match_angle, 'alert-error', obj_parent, obj_evidence, true)
        return
      }
      
      // perform analysis
      // - if this is an angle measurement, calculate the % so can do comparisson
      // - otherwise, compare by =, < or >
      var validates = false;
      var user_entered_value;
      if (evidence[0] != null){
        user_entered_value = parseFloat(evidence[0][0]);
      }
      if (is_angle){
        // if height/depth provided, use it
        // else use degrees
        if (evidence[0] != null && evidence[0].length > 0 && evidence[1] != null && evidence[1].length > 0){
          // height/depth
          // - eq = height/depth * 100
          user_entered_value = parseFloat(evidence[0][0]) / parseFloat(evidence[1][0]) * 100;
        }else{
          // degrees
          // - eq = tan(degrees) * 100
          user_entered_value = Math.tan(parseFloat(evidence[2][0])*Math.PI/180)*100;
        }
      }

      // figure out what comparisson to use
			var indexG = val_eq.indexOf(">");
			var indexL = val_eq.indexOf("<");
			if (indexG >= 0 && indexL >= 0) {
        values = val_eq.split(' and ');
        if (indexG == 0){
			    var value1 = parseFloat(values[0].replace('>', ''));
			    var value2 = parseFloat(values[1].replace('<', ''));
					if (user_entered_value >= value1 && user_entered_value <= value2){
					  validates = true;
					}
        }else {
			    var value1 = parseFloat(values[0].replace('<', ''));
			    var value2 = parseFloat(values[1].replace('>', ''));
					if (user_entered_value <= value1 && user_entered_value >= value2){
					  validates = true;
					}
        }          
			} else if (indexL >= 0) {
				// set to <=
		    var value = parseFloat(val_eq.replace('<', ''));
				if (user_entered_value <= value){
				  validates = true;
				}
			} else if (indexG >= 0) {
				// set to >=
		    var value = parseFloat(val_eq.replace('>', ''));
				if (user_entered_value >= value){
				  validates = true;
				}
			} else {
				// set to '='
				if (user_entered_value == parseFloat(val_eq)){
				  validates = true;
				}
			}
      
      if (validates){
        show_question_evidence_message(gon.validation_passed, 'alert-success', obj_parent, obj_evidence)
        $(obj_evidence).find(' + div > input[type="radio"]').prop('checked', true).removeProp('disabled');
        $(obj_evidence).find('+ div + div > input[type="radio"]').attr('disabled', true);
      }else{
        show_question_evidence_message(gon.validation_failed, 'alert-success', obj_parent, obj_evidence)
        $(obj_evidence).find(' + div > input[type="radio"]').attr('disabled', true);
        $(obj_evidence).find('+ div + div > input[type="radio"]').prop('checked', true).removeProp('disabled');
      }
      
      // if this is an angle, record the value
      if(is_angle){
        $(obj_evidence).find('input.question-evidence-angle').val(user_entered_value);
      }
      
      evidence_angle

      // make sure the submit button is showing
      $('form.place #submit-button').removeClass('accessibly-hidden');


      $(this).parent().find('.evidence-message-container').attr('aria-busy', 'true');
    });
    

  }


  /*************************************************/
  /* show map for place show */
  if (gon.show_place_map){
      map = L.map(gon.map_id).setView([gon.lat, gon.lon], gon.zoom);
      L.tileLayer(gon.tile_url, {maxZoom: gon.max_zoom}).addTo(map);
		  map.attributionControl = false;
		  map.zoomControl = true;
		
      marker = L.marker([gon.lat, gon.lon], {icon: L.icon(default_leaflet_icon_options)}).addTo(map);

      // show popup
      if (gon.marker_popup){
        marker.bindPopup(gon.marker_popup).openPopup();
      }

      $('#place_carousel').carousel();
  }
  


});
