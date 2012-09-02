// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .


var monitoring_charts = new Object();

function init_monitoring_chart(metric_name, series_data) {
    var chart;

    var chart_title = metric_name;
    var xlabel = "Time";
    var ylabel = "";

    if(metric_name == "cpu") {
        chart_title = "CPU servers utilization";
        ylabel = "CPU load [%]";
    } else if(metric_name == "memory") {
        chart_title = "Free operational memory";
        ylabel = "Free memory [MB]";
    }

  chart = new Highcharts.Chart({
    chart: {
      renderTo: 'chart_container_' + metric_name,
      type: 'line',
      marginRight: 130,
      marginBottom: 25,
            zoomType: 'x'
    },
    title: {
      text: chart_title,
      x: 50 //center
    },
    xAxis: {
            type: "datetime",
            text: xlabel,
            maxZoom: 300 * 1000
    },
    yAxis: {
      title: {
        text: ylabel
      },
      plotLines: [{
        value: 0,
        width: 1,
        color: '#808080'
      }]
    },
    tooltip: {
      formatter: function() {
          return '<b>'+ this.series.name +'</b><br/>'+
          new Date(this.x) +': '+ this.y;
      }
    },
    legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'top',
      x: -10,
      y: 100,
      borderWidth: 0
    },
    series: series_data
  });

  monitoring_charts[metric_name] = chart;
}
