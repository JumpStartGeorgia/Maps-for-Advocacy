  $(function () {
    if (gon.load_place_photos_path){
      // Initialize the jQuery File Upload widget:
      $('#fileupload').fileupload();
      // 
      // Load existing files:
      $.getJSON(gon.load_place_photos_path, function (files) {
        var fu = $('#fileupload').data('blueimpFileupload'), 
          template;
        fu._adjustMaxNumberOfFiles(-files.length);
        template = fu._renderDownload(files)
          .appendTo($('#fileupload .files'));
        // Force reflow:
        fu._reflow = fu._transition && template.length &&
          template[0].offsetWidth;
        template.addClass('in');
        $('#loading').remove();
      });
    }
  });

