window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.authors =
  init: ->
    $('#add-author').on 'click', (e) =>
      e.preventDefault()
      @appendAuthorForm()

  appendAuthorForm: ->
    li = $('<li class="author">')
    li.html $('#author-form-template').html()
    li.appendTo $('ul.authors')

