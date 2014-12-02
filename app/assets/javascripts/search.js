$(document).ready(function(){
  $.extend( $.fn.dataTableExt.oStdClasses, {
      "sWrapper": "dataTables_wrapper form-inline"
  });

  /* get sorting to work with textboxes in table */
  $.fn.dataTableExt.afnSortData['dom-text'] = function  ( oSettings, iColumn )
  {
	  return $.map( oSettings.oApi._fnGetTrNodes(oSettings), function (tr, i) {
		  return $('td:eq('+iColumn+') input', tr).val();
	  } );
  }
  


  $('#users-datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bAutoWidth": false,
    "sAjaxSource": $('#users-datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aoColumns": [
      { "bSortable": false },
      null,
      null,
      null,
      { "bSortable": false },
      null
    ],
    "aaSorting": [[4, 'desc']]
  });


  /*************************************************/
  /* question pairing disability (help text) */
  help_text_dt = $('#help-text-datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bAutoWidth": false,
    "sAjaxSource": $('#help-text-datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aoColumnDefs": [
      {
        "bSortable": false,
        "aTargets": [ 6 ]
      }
    ],
    "fnServerParams": function ( aoData ) {
      aoData.push( { name: "is_certified", value: $('#help-text-admin #help_text_filter_certified').val()} ),
      aoData.push( { name: "type", value: $('#help-text-admin #help_text_filter_type').val()} ),
      aoData.push( { name: "category", value: $('#help-text-admin #help_text_filter_category').val()} )
    }
  });

  // when options change, update datatable
  $('#help-text-admin #help_text_filter_certified').change(function(){
    help_text_dt.fnDraw();
  });
  $('#help-text-admin #help_text_filter_type').change(function(){
    help_text_dt.fnDraw();
  });
  $('#help-text-admin #help_text_filter_category').change(function(){
    help_text_dt.fnDraw();
  });


  /*************************************************/
  /* questions */

  $('#question-categories').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bAutoWidth": false,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aoColumnDefs": [
      {
        "bSortable": false,
        "aTargets": [ -1 ]
      }
    ]
  });


  $('#question-category-questions').dataTable({
    "sDom": "<'row-fluid'<'span2'<'sort_order_button'>><'span4'l><'span6'f>r>t<'row-fluid'<'span2'<'sort_order_button'>><'span4'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bAutoWidth": false,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aoColumns": [
      { "sSortDataType": "dom-text", "sType": "numeric" },
			null,
			null,
			null
		],
		"fnInitComplete": function(oSettings, json) {
      $('.sort_order_button').html($('#submit_sort_order').html());
    },
    "aoColumnDefs": [
      {
        "bSortable": false,
        "aTargets": [ -1 ]
      }
    ]
  });
  
  $('#existing-questions').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bAutoWidth": false,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aLengthMenu": [ 5, 10, 15, 20 ],
    "iDisplayLength": 5,
    "aaSorting": [[1, 'asc']]
  });
  
  
  /*************************************************/
  /* venues */
  
  $('#venue-categories').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bAutoWidth": false,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aoColumnDefs": [
      {
        "bSortable": false,
        "aTargets": [ -1 ]
      }
    ]
  });

  $('#venue-category-venues').dataTable({
    "sDom": "<'row-fluid'<'span2'<'sort_order_button'>><'span4'l><'span6'f>r>t<'row-fluid'<'span2'<'sort_order_button'>><'span4'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bAutoWidth": false,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aoColumns": [
      { "sSortDataType": "dom-text", "sType": "numeric" },
			null,
			null,
			null
		],
		"fnInitComplete": function(oSettings, json) {
      $('.sort_order_button').html($('#submit_sort_order').html());
    },
    "aoColumnDefs": [
      {
        "bSortable": false,
        "aTargets": [ -1 ]
      }
    ]
  });
  
  /*************************************************/
  /* places */
  
  $('#place-venue-categories').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bAutoWidth": false,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aoColumnDefs": [
      {
        "bSortable": false,
        "aTargets": [ -1 ]
      }
    ]
  });




});
