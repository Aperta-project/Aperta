$(document).ready ->
  if $('#body_editable').length > 0
    CKEDITOR.inline( 'body_editable' )
    CKEDITOR.inline( 'abstract_editable' )

  $('#save_button').on 'click', (e) ->
    e.preventDefault()
    $.ajax
      url: $(this).data('url') + '.json'
      method: "PUT"
      data:
        paper:
          title: $.trim($('#title_editable').text())
          body: $.trim($('#body_editable').text())
          abstract: $.trim($('#abstract_editable').text())
          short_title: $.trim($('#short_title_editable').text())
      success:
        window.location = "/"
