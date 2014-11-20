$(document).ready(function(){
  // turn venue list into menu
  $('form#print_options ul#venues').menu();
  
  // update form when certified value is set
  $('form#print_options input[name="assessment_type"]').change(function(){


    if ($(this).val() == 'true'){
      // certified

      // show question categories
      $('form#print_options #question_categories').removeClass('accessibly-hidden');

      // evaluation types
      // hide all first and then turn on certified
      $('form#print_options #evaluation_types ul li').addClass('accessibly-hidden');
      $('form#print_options #evaluation_types ul li[data-certified="true"]').removeClass('accessibly-hidden');

      // questions
      $('#print_area #print_questions #public-questions').addClass('accessibly-hidden');
      $('#print_area #print_questions #certified-questions').removeClass('accessibly-hidden');

    }else{
      // public

      // hide question categories
      $('form#print_options #question_categories').addClass('accessibly-hidden');

      // evaluation types
      // hide all first and then turn on public
      $('form#print_options #evaluation_types ul li').addClass('accessibly-hidden');
      $('form#print_options #evaluation_types ul li[data-public="true"]').removeClass('accessibly-hidden');

      // questions
      $('#print_area #print_questions #public-questions').removeClass('accessibly-hidden');
      $('#print_area #print_questions #certified-questions').addClass('accessibly-hidden');      
    }

    // show all venue questions
    $('#print_questions .venue_questions').show();

  });

  // when select venue, show venue in form and show correct questions
  $('form#print_options ul#venues a').click(function(e){
    e.preventDefault();


    if ($(this).data('id') == '0'){
      // selected 'all' option
      // - show all categories
      $('#venue_name #venue_name_selection').show();

      // hide span
      $('#venue_name span').empty();

      // show all venue questions
      $('#print_questions .venue_questions').show();

    }else{
      // show selected category

      // hide all of the categories
      $('#venue_name #venue_name_selection').hide();

      // update name
      $('#venue_name span').html($(this).html());

      // hide all venue questions
      $('#print_questions .venue_questions').hide();

      var id;
      if ($('form#print_options input[name="assessment_type"]').length > 0 && 
          $('form#print_options input[name="assessment_type"]:checked').val() == 'true' &&
          $(this).data('cert-id') != undefined){

        id = $(this).data('cert-id').toString();          
      }else if ($(this).data('public-id') != undefined){
        id = $(this).data('public-id').toString();
      }

      // if this venue has questions, show them    
      if (id != undefined){
        // show the correct venue questions
        $('#print_questions .venue_questions[data-id="' + id + '"]').show();
      }
    }    
  });

  // when user selects question category, update that category visibility
  $('form#print_options input[name="question_category"]').change(function(){
    var checked = 'form#print_options input[name="question_category"]:checked';

    // reset and hide all question categories
    $('#print_area #print_questions .question-categories[data-common="true"]').hide();

    if ($(checked).length > 0){

      // for each selected, show it
      $(checked).each(function(){
        $('#print_area #print_questions .question-categories[data-common="true"][data-id="' + $(this).val() + '"').show();
      });
    }else{
      // nothing selected so show all
      $('#print_area #print_questions .question-categories').show();
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
