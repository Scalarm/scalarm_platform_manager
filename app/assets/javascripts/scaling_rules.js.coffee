# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class window.MonitoringMetricSelector

  constructor: (@monitoringMetrics) ->
    @fillHostTag()


  fillHostTag: ->
    for host, metricsList of @monitoringMetrics
      $("#host").append($("<option></option>").attr("value", host).html(host))
    $("#host").bind("change", @fillMetricTag)
    @fillMetricTag()

  fillMetricTag: =>
    $("#metric").html("")
    host = $("#host option:selected").attr("value")

    for i, metric_name of @monitoringMetrics[host]
      $("#metric").append($("<option></option>").attr("value", metric_name).html(metric_name))



