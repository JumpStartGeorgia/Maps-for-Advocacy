
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
    "aaSorting": [[2, 'desc']]
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
