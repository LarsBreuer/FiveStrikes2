jQuery ->
  $('a[rel*=facebox]').facebox()

# facebox - make modal

$(document).bind "loading.facebox", ->
  $(document).unbind "keydown.facebox"
  $("#facebox_overlay").unbind "click"