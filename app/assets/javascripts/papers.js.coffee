$(document).ready ->
  if $('[contenteditable!=false]').length > 0
    for elementId in ['body_editable', 'abstract_editable']
      CKEDITOR.inline elementId,
        extraPlugins: 'sharedspace'
        removePlugins: 'floatingspace,resize'
        sharedSpaces:
          top: 'ckeditor-toolbar'

  $('#save_button').on 'click', (e) ->
    e.preventDefault()
    $.ajax
      url: $(this).data('url') + '.json'
      method: "PUT"
      data:
        paper:
          title: $.trim($('#title_editable').text())
          body: CKEDITOR.instances.body_editable.getData()
          abstract: CKEDITOR.instances.abstract_editable.getData()
          short_title: $.trim($('#short_title_editable').text())
      success:
        window.location = "/"
