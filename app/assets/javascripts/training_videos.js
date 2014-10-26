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
    console.log('before: ' + $('#' + embed_form_id).val() + ' ||| html = ' + $('#' + embed_html_id).html().trim());
    $('#' + embed_form_id).val($('#' + embed_html_id).html().trim());
    console.log('after: ' + $('#' + embed_form_id).val() + ' ||| html = ' + $('#' + embed_html_id).html().trim());
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
    
console.log('----video url for ' + embed_locale + '; url = ' + url);

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

});