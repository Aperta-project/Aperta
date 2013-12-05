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

    $('#authors').click => @bindCloseToUpdateAuthors()
    @updateAuthors()

  authors: ->
    authorsArray = []
    $('li.author').each (index, value) ->
      li = $(this)
      author =
        first_name: $('.author-first-name', li).text().trim()
        last_name: $('.author-last-name', li).text().trim()
        affiliation: $('.author-affiliation', li).text().trim()
        email: $('.author-email', li).text().trim()
      if author.first_name.length > 0 || author.last_name.length > 0 || author.affiliation.length > 0 || author.email.length > 0
        authorsArray.push author
    authorsArray

  fixArticleControls: ->
    $('#control-bar-container').scrollToFixed()
    $('#toolbar').scrollToFixed(marginTop: $('#control-bar-container').outerHeight(true))
    $('#tahi-container > main > aside').scrollToFixed
      marginTop: $('#control-bar-container').outerHeight(true)
      unfixed: ->
        $(this).css('top', '0px')

  instantiateEditables: ->
    if $("[contenteditable]").length > 0
      Tahi.body_editable = new Tahi.RichEditableElement(document.getElementById 'body-editable')
      Tahi.abstract_editable = new Tahi.RichEditableElement(document.getElementById 'abstract-editable')
      Tahi.title_editable = new Tahi.PlaceholderElement(document.getElementById 'title-editable')

  updateAuthors: ->
    authors = Tahi.papers.authors()
    if authors.length > 0
      authorNames = authors.map (author) -> "#{author.first_name} #{author.last_name}"
      $('#authors').text authorNames.join(', ')
    else
      $('#authors').text 'Click here to add authors'

  bindCloseToUpdateAuthors: ->
    $('.close-overlay').on 'click', =>
      @updateAuthors()

$(document).ready ->
  $('#save-button').on 'click', (e) ->
    e.preventDefault()
    Tahi.body_editable.clearPlaceholder()
    Tahi.abstract_editable.clearPlaceholder()
    Tahi.title_editable.clearPlaceholder()

    $.ajax
      url: $(this).attr('href')
      method: "POST"
      data:
        _method: "patch"
        paper:
          title: $.trim($('#title-editable').text())
          body: CKEDITOR.instances['body-editable'].getData()
          abstract: CKEDITOR.instances['abstract-editable'].getData()
          short_title: $.trim($('#short-title-editable').text())
          authors: (-> JSON.stringify Tahi.papers.authors())()

      success: ->
        location.href = "/"
    false
