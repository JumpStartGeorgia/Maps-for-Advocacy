$(document).ready(function(){

  // load the chart data for a place
  if (gon.place_chart_data){
  
    $('#place_chart').highcharts({
        chart: {
            type: 'spline'
        },
        title: {
            text: gon.place_chart_title
        },
        xAxis: {
            title: {
                text: gon.place_chart_xaxis
            },
            type: 'datetime',
            dateTimeLabelFormats: { 
                second: '%d %b %H:%M',
                minute: '%d %b %H:%M',
                hour: '%d %b %H:%M',
                day: '%d %b',
                month: '%d %b',
                year: '%b %Y'
            }        
        },
        yAxis: {
            title: {
                text: gon.place_chart_yaxis
            },
            min: 0,
            max: 100
        },
        tooltip: {
            formatter: function() {
                    return '<b>'+ this.series.name +'</b><br/>'+
                    Highcharts.dateFormat('%d %b %Y', this.x) +': '+ Highcharts.numberFormat(this.y, 2) +' %';
            }
        },
        series: gon.place_chart_data

    });
  
  }

});
