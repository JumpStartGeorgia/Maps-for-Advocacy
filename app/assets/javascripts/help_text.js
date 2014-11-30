$(document).ready(function(){

  /* place show page */
  function resize_help_text_filters(){
    $('#help-text-admin #help_text_filter_certified').select2({width:'element'});
    $('#help-text-admin #help_text_filter_type').select2({width:'element'});
    $('#help-text-admin #help_text_filter_category').select2({width:'element'});
  }

  $(window).bind('resize', resize_help_text_filters);
  resize_help_text_filters();

  // when the certified status changes, update the type filter and question category filter
  $('#help-text-admin #help_text_filter_certified').on('change', function(e){
    var val = $(this).val();
    var type_val = $('#help-text-admin #help_text_filter_type').val();

    // turn off all selections
    $('#help-text-admin #help_text_filter_type option').addClass('accessibly-hidden');
    $('#help-text-admin #help_text_filter_category option').addClass('accessibly-hidden');

    if (val == 'true'){
      // certified
      $('#help-text-admin #help_text_filter_type option[data-certified="true"]').removeClass('accessibly-hidden');
      $('#help-text-admin #help_text_filter_category option[data-certified="true"]').removeClass('accessibly-hidden');

    }else{
      // public
      $('#help-text-admin #help_text_filter_type option[data-public="true"]').removeClass('accessibly-hidden');
      $('#help-text-admin #help_text_filter_category option[data-public="true"]').removeClass('accessibly-hidden');
    }

    // if old type value is no longer visible, reset to all option
    if ($('#help-text-admin #help_text_filter_type option[value="' + type_val + '"]').hasClass('accessibly-hidden')){
      // not visible, reset
      $('#help-text-admin #help_text_filter_type').val('0');
    }
    if ($('#help-text-admin #help_text_filter_category option[value="' + type_val + '"]').hasClass('accessibly-hidden')){
      // not visible, reset
      $('#help-text-admin #help_text_filter_category').val('0');
    }

  });

});