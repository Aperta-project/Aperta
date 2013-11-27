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
    $('input[type=submit]', li).on 'click', (e) =>
      e.preventDefault()
      @htmlify li[0]
    li.appendTo $('ul.authors')

  htmlify: (element) ->
    $el = $(element)
    firstName = $('[name=author_first_name]', $el).val()
    lastName = $('[name=author_last_name]', $el).val()
    email = $('[name=author_email]', $el).val()
    affiliation = $('[name=author_affiliation]', $el).val()
    $el.html """
      <h4>
        <span class="author-first-name">#{firstName}</span>
        <span class="author-last-name">#{lastName}</span>
      </h4>
      <h4 class="author-email">#{email}</h4>
      <h4 class="author-affiliation">#{affiliation}</h4>
    """
