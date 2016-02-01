jQuery ->
  $('a[rel*=facebox]').facebox()

# facebox - make modal

$(document).bind "loading.facebox", ->
  $(document).unbind "keydown.facebox"
  $("#facebox_overlay").unbind "click"

# alert box html for js.erb files

@alert_box = (level, close_btn, msg) ->
  if close_btn == 'y'
    html = \
    "<div class='alert fade in alert-#{level}'>
    <button class='close' data-dismiss='alert'>\&times;</button>#{msg}</div>"
  else
    html = \
    "<div class='alert fade in alert-#{level}'>#{msg}</div>"
  return html