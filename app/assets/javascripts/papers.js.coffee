window.Tahi = {}
Tahi.papers =
  init: ->
    $('#add_author').on 'click', (e) ->
      e.preventDefault()
      li = $('<li class="author">')
      li.html $('#author-template').html()
      li.appendTo $('ul.authors')
    @fixArticleControls()
    unless window.jasmine?
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
      for elementId in ['body_editable', 'abstract_editable']
        CKEDITOR.inline elementId,
          extraPlugins: 'sharedspace'
          removePlugins: 'floatingspace,resize'
          sharedSpaces:
            top: 'toolbar'
          toolbar: [
            [ 'Styles', 'Format', 'FontSize' ]
            [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ]
            [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', 'Blockquote', 'Table' ]
            [ 'PasteFromWord' ],
            [ 'Link', 'Unlink', 'Anchor' ]
            [ 'Find', 'Replace', '-', 'Scayt' ]
          ]
          extraAllowedContent:
            p:
              classes: 'placeholder'

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

    if $('#abstract_editable').text().trim() == ''
      placeholder_text = $('#abstract_editable').attr('placeholder')
      CKEDITOR.instances.abstract_editable.setData "<p class='placeholder'>#{placeholder_text}</p>"

      CKEDITOR.instances.abstract_editable.on 'focus', ->
        if $.trim(CKEDITOR.instances.abstract_editable.getData()) == '<p class="placeholder">Type the abstract of your article here</p>'
          CKEDITOR.instances.abstract_editable.setData ''

      CKEDITOR.instances.abstract_editable.on 'blur', ->
        if $.trim(CKEDITOR.instances.abstract_editable.getData()) == ''
          CKEDITOR.instances.abstract_editable.setData '<p class="placeholder">Type the abstract of your article here</p>'

    if $('#body_editable').text().trim() == ''
      placeholder_text = $('#body_editable').attr('placeholder')
      CKEDITOR.instances.body_editable.setData "<p class='placeholder'>#{placeholder_text}</p>"

      CKEDITOR.instances.body_editable.on 'focus', ->
        if $.trim(CKEDITOR.instances.body_editable.getData()) == '<p class="placeholder">Type the body of your article here</p>'
          CKEDITOR.instances.body_editable.setData ''

      CKEDITOR.instances.body_editable.on 'blur', ->
        if $.trim(CKEDITOR.instances.body_editable.getData()) == ''
          CKEDITOR.instances.body_editable.setData '<p class="placeholder">Type the body of your article here</p>'


$(document).ready ->


  $('#save_button').on 'click', (e) ->
    e.preventDefault()
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
