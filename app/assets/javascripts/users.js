$(document).ready(function(){
  function show_user_organizations(ths){
    // if the role is >= 60, show organizations
    if (parseInt($(ths).val()) >= 60){
      $('form.user div#user_organizations').attr('aria-hidden', false);
    }else{
      $('form.user div#user_organizations').attr('aria-hidden', true);
    }
  }

  $('form.user select#user_role').change(function(){
    show_user_organizations(this);
  });
  
  show_user_organizations($('form.user select#user_role'));

});
