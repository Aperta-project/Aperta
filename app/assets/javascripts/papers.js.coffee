window.Tahi ||= {}

Tahi.papers =
  init: ->
    $('#add_author').on 'click', (e) ->
      e.preventDefault()
      li = $('<li class="author">')
      li.html $('#author-template').html()
      li.appendTo $('ul.authors')
    @fixArticleControls()
    @instantiateEditables()
    @togglePlaceholders()

  authors: ->
    authorsArray = []
    $('li.author').each (index, value) ->
      authorsArray.push({
        first_name: $(this).children('.author-first-name').text()
        last_name: $(this).children('.author-last-name').text()
        affiliation: $(this).children('.author-affiliation').text()
        email: $(this).children('.author-email').text()
      })
    authorsArray

  fixArticleControls: ->
    $('header').scrollToFixed()
    $('#toolbar').scrollToFixed(marginTop: $('header').outerHeight(true))
    $('main > aside').scrollToFixed
      marginTop: $('header').outerHeight(true)
      unfixed: ->
        $(this).css('top', '0px')

  instantiateEditables: ->
    if $("[contenteditable]").length > 0
      Tahi.body_editable = new Tahi.RichEditableElement(document.getElementById 'body_editable')
      Tahi.abstract_editable = new Tahi.RichEditableElement(document.getElementById 'abstract_editable')

  togglePlaceholders: ->
    if $('.title h2').text().trim() == ''
      title_placeholder_text = $('.title h2').attr('placeholder')
      $('.title h2').html('<span class="placeholder">' + title_placeholder_text + '</span>')
      $('.title h2').on 'click', (e) ->
        if $('.title h2 span.placeholder').length > 0
          $(this).empty()

      $('.title h2').on 'blur', (e) ->
        if $(this).text().trim() == ''
          $(this).html('<span class="placeholder">' + title_placeholder_text + '</span>')

$(document).ready ->


  $('#save_button').on 'click', (e) ->
    e.preventDefault()
    Tahi.body_editable.clearPlaceholder()
    Tahi.abstract_editable.clearPlaceholder()
    if $('.title h2 span.placeholder').length > 0
      $('.title h2').empty()
    $.ajax
      url: $(this).data('url') + '.json'
      method: "POST"
      data:
        _method: "patch"
        paper:
          title: $.trim($('#title_editable').text())
          body: CKEDITOR.instances.body_editable.getData()
          abstract: CKEDITOR.instances.abstract_editable.getData()
          short_title: $.trim($('#short_title_editable').text())
          authors: (-> JSON.stringify Tahi.papers.authors())()

      success: ->
        location.href = "/"
    false

  Tahi.papers.init()
