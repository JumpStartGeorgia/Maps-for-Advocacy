var timerCount = 0;
var embed_url_id;
var embed_html_id;
var embed_form_id;
var embed_locale;

// hide the embed error and show link
function resetEmbedMessages(){
  timerCount = 0;
  // turn off error/show link
  $('.video-embed-messages[data-locale="' + embed_locale + '"] .video-embed-success').attr('aria-hidden', 'true');
  $('.video-embed-messages[data-locale="' + embed_locale + '"] .video-embed-fail').attr('aria-hidden', 'true');
}

function resetEmbedFields(){
  timerCount = 0;
  // reset embed code
  $('form.training_video input.video_embed[data-locale="' + embed_locale + '"]').val('');
  $('form.training_video .video_embed_html[data-locale="' + embed_locale + '"]').html('');
}

// the url could not be formatted for embedding
function ollyFail(){
  resetEmbedMessages();
  $('.video-embed-messages[data-locale="' + embed_locale + '"] .video-embed-fail').attr('aria-hidden', 'false');
}

// if the embed codes has been generated, show link to view it
// else try again
function timerOllyCompelte() {
  timerCount += 1;
  if ($('#' + embed_html_id).html().trim().length > 0){
    resetEmbedMessages();
    $('#' + embed_form_id).val($('#' + embed_html_id).html().trim());
    $('.video-embed-messages[data-locale="' + embed_locale + '"] .video-embed-success').attr('aria-hidden', 'false');
    $('.video-embed-messages[data-locale="' + embed_locale + '"] .video-embed-success a').focus();
  }else{
    setTimeout(function() {
        timerOllyCompelte();
    }, 500)
  }

}

// check if url is in correct format
function isUrl(s) {
  var regexp = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
  return regexp.test(s);
}

$(document).ready(function() {

  // when a url is added to the training video form, get the embed code for it
  $('form.training_video input.video_url').focusout(function(){
    var url = $(this).val();

    embed_locale = $(this).data('locale');
    embed_url_id = $(this).attr('id');
    embed_html_id = 'video_embed_html_' + embed_locale;
    embed_form_id = $(this).attr('id').replace('video_url', 'video_embed');

    resetEmbedFields();
    
    if (url.length > 0 && isUrl(url)){
      olly.embed(url, document.getElementById(embed_html_id), 'timerOllyCompelte', 'ollyFail');
    }else{
      ollyFail();
    }
  });

  // when training video form loads, check if embed code already exists
  // if it does, show the success button
  $('.video_embed_html').each(function(){
    if ($(this).html().trim().length > 0){
      $('.video-embed-messages[data-locale="' + $(this).data('locale') + '"] .video-embed-success').attr('aria-hidden', 'false');
    }

  });


  /* for watching a training video */
  if (gon.record_progress_path){
    // ajax call to make the update
    function update_video_progress(){
      $.ajax({
        type: "POST",
        dataType: 'json',
        url: gon.record_progress_path,
        data: {
          pre_survey_answer: $('#training-video-survey #pre-survey input:checked').val(),
          post_survey_answer: $('#training-video-survey #post-survey input:checked').val(),
          watched_video: $('#training-video-survey #video #btn-video').data('watched'),
          survey_id: $('#survey_id').val()
        }
      }).always(function(data){
        if (data != undefined && data.survey_id != undefined && $('#survey_id').val() == ''){
          $('#survey_id').val(data.survey_id);
        }
      });
    }

    // switch to video
    $('#training-video-survey #pre-survey #btn-pre-survey').click(function(){
      // save response
      update_video_progress();

      // turn on/off sections
      $('#training-video-survey #pre-survey').attr('aria-hidden', 'true');
      $('#training-video-survey #video').attr('aria-hidden', 'false');
    });
    // switch to post-survey
    $('#training-video-survey #video #btn-video').click(function(){
      // record that video was watched
      $('#training-video-survey #video #btn-video').data('watched', 'true');

      // save response
      update_video_progress();

      // turn on/off sections
      $('#training-video-survey #video').attr('aria-hidden', 'true')
      $('#training-video-survey #post-survey').attr('aria-hidden', 'false');
    });
    // switch to results
    $('#training-video-survey #post-survey #btn-post-survey').click(function(){
      // save response
      update_video_progress();

      // get answer and show proper response
      if ($('#training-video-survey #post-survey input:checked').val() == $('#training-video-survey #results').data('correct').toString()){
        $('#training-video-survey #results #correct-answer').attr('aria-hidden', 'false');
      }else{
        $('#training-video-survey #results #wrong-answer').attr('aria-hidden', 'false');
      }

      // turn on/off sections
      $('#training-video-survey #post-survey').attr('aria-hidden', 'true');
      $('#training-video-survey #results').attr('aria-hidden', 'false');
    });

    // when answer is selected, show continue button
    $('#training-video-survey #pre-survey input, #training-video-survey #post-survey input').change(function(){
      $(this).closest('.survey-answers').find('+ .survey-btn').attr('aria-hidden', 'false');
    });
  }
});