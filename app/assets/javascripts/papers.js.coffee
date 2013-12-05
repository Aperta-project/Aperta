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

    $('#paper-authors').click => @bindCloseToUpdateAuthors()
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
    $('#tahi-container > main > aside > div').scrollToFixed
      marginTop: $('#control-bar-container').outerHeight(true)
      unfixed: ->
        $(this).css('top', '0px')

  instantiateEditables: ->
    if $("[contenteditable]").length > 0
      Tahi.body_editable = new Tahi.RichEditableElement($('#paper-body[contenteditable]')[0])
      Tahi.abstract_editable = new Tahi.RichEditableElement($('#paper-abstract[contenteditable]')[0])
      Tahi.title_editable = new Tahi.PlaceholderElement($('#paper-title[contenteditable]')[0])

  updateAuthors: ->
    authors = Tahi.papers.authors()
    if authors.length > 0
      authorNames = authors.map (author) -> "#{author.first_name} #{author.last_name}"
      $('#paper-authors').text authorNames.join(', ')
    else
      $('#paper-authors').html '<span class="placeholder">Click here to add authors</span>'

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
          title: $.trim($('#paper-title').text())
          body: CKEDITOR.instances['paper-body'].getData()
          abstract: CKEDITOR.instances['paper-abstract'].getData()
          short_title: $.trim($('#paper-short-title').text())
          authors: (-> JSON.stringify Tahi.papers.authors())()

      success: ->
        location.href = "/"
    false
