$(document).ready ->
  CKEDITOR.disableAutoInline = true
  CKEDITOR.inline( 'body_editable' )
  CKEDITOR.inline( 'abstract_editable' )

  $('#save_button').on 'click', (e) ->
    $.ajax
      url: $(this).data('url') + '.json'
      method: "PUT"
      data:
        paper:
          title: $('.title').text()
          body: CKEDITOR.instances.body_editable.getData()
          abstract: CKEDITOR.instances.abstract_editable.getData()
          short_title: $('.short_title').text()
      success:
        window.location = "/"
