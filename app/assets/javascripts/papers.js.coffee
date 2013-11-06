
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
        toolbarGroups: [
          { name: 'styles' }
          { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] }
          { name: 'clipboard',   groups: [ 'clipboard', 'undo' ] }
          { name: 'editing',     groups: [ 'find', 'selection', 'spellchecker' ] }
          { name: 'paragraph',   groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ] }
          { name: 'links' }
          { name: 'tools' }
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
