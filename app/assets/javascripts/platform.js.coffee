# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.executeInstallation = (installation_path) ->
  window.location.href = installation_path + "?manager_type=" + $('#install_manager_type :selected').val()

window.execute = (global_start_path, global_stop_path) ->
  manager_type = $('#manager_type :selected').val()
  global_action = $('#global_action :selected').val()
  count = 1
  if manager_type == "experiment"
    count = 8

  if global_action == "start"
    window.location.href = global_start_path + "?manager_type=" + manager_type + "&number=" + count
  else
    window.location.href = global_stop_path + "?manager_type=" + manager_type + "&number=" + count

