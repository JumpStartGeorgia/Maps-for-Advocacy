$(document).ready(function(){
  // turn venue list into menu
  $('form#print_options ul#venues').menu();
  
  // when select venue, show venue in form and show correct questions
  $('form#print_options ul#venues a').click(function(e){
    e.preventDefault();

    // hide all venue questions
    $('#print_questions .venue_questions').hide();

    // update name
    $('#venue_name span').html($(this).html());

    // if this venue has questions, show them    
    if ($(this).data('id') != undefined){
      // show the correct venue questions
      $('#print_questions .venue_questions[data-id="' + $(this).data('id').toString() + '"]').show();
    }
    
  });

  // when user selects evaluation type, update questions and heading selection
  $('form#print_options input[name="evaluation_type"]').change(function(){
    var checked = 'form#print_options input[name="evaluation_type"]:checked';

    // reset and show all questions and headers
    $('#print_questions .question_container, #print_questions h4, #print_questions h5').show();

    if ($(checked).length > 0){

      // get all ids of eval type
      var ids_hide = $('form#print_options #evaluation_types').data('evaluation-type-ids').slice();
    
      // hide all types first
      $('#print_area #print_heading .evaluation_type').hide();

      // for each selected, show it
      // - remove ids from ids_hide
      $(checked).each(function(){
        $('#print_area #print_heading .evaluation_type[data-id="' + $(this).val() + '"').show();
        ids_hide.splice( $.inArray(parseInt($(this).val()), ids_hide), 1 );
      });
      
      // create all possible combinations of these ids
      var combination_ids_hide = combinations(ids_hide);
      // hide questions that only have ids in ids_hide
      for(var i=0;i<combination_ids_hide.length;i++){
        var nums = combination_ids_hide[i].split(';').sort();
        if (nums.length > 0){
          $('#print_questions .question_container[data-disability-ids="[' + nums.join(', ') + ']"]').hide();  
        }
      }
      
      // hide headers if no questions
      $('#print_questions h4, #print_questions h5').each(function(){
        if ($(this).find('+ div.questions .question_container').filter(':visible').length == 0){
          $(this).hide();
        }
      }); 
      
    
    }else{
      // nothing selected so show all
      $('#print_area #print_heading .evaluation_type').show();
    }
  });


  // when change layout, add/remove landscape class to adjust width and layout of page
  $('form#print_options input[name="layout"]').change(function(){
    if ($(this).val() == 'landscape'){
      $('#print_area').addClass('landscape');
    }else{
      $('#print_area').removeClass('landscape');
    }
  });

  // when click print button, if landscape is selected, show alert
  $('form#print_options a#btn_print').click(function(e){
    e.preventDefault();
    
    if ($('#print_area').hasClass('landscape')){
      alert(gon.print_landscape_alert);
    }
    
    window.print();
  });
  

});
