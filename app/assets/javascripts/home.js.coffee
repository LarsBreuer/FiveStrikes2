$(document).ready ->
  $('#top-search-form').submit ->
    $.ajax '/line_items/create_line_items',
        type: 'GET',
        data: { query: $("#query").val(), choice_id: $("#choice_id").val() }
    false

  setSideBarClickListener()
