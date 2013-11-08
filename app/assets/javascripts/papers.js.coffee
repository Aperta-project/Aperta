window.Tahi = {}
Tahi.papers =
  init: ->
    $('#add_author').on 'click', (e) ->
      e.preventDefault()
      $('<li class="author">').appendTo $('ul.authors')

$(document).ready ->
  if $('[contenteditable!=false]').length > 0
    for elementId in ['body_editable', 'abstract_editable']
      CKEDITOR.inline elementId,
        extraPlugins: 'sharedspace'
        removePlugins: 'floatingspace,resize'
        sharedSpaces:
          top: 'ckeditor-toolbar'
        toolbar: [
          [ 'Styles', 'Format', 'FontSize' ]
          [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ]
          [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', 'Blockquote', 'CreateDiv']
          [ 'PasteFromWord' ],
          [ 'Link', 'Unlink', 'Anchor']
          [ 'Find', 'Replace', '-', 'Scayt', '-', 'ShowBlocks' ]
        ]

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
  Tahi.papers.init()
