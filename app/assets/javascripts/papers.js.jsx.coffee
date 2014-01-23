###* @jsx React.DOM ###

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

    $('#paper-authors.editable').click => @bindCloseToUpdateAuthors()
    @initAuthors()

    $('#save-button').click (e) => @savePaper e

  authorArray: ->
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
      @bodyEditable = new Tahi.RichEditableElement($('#paper-body[contenteditable]')[0])
      @abstractEditable = new Tahi.RichEditableElement($('#paper-abstract[contenteditable]')[0])
      @shortTitleEditable = new Tahi.PlaceholderElement($('#paper-short-title[contenteditable]')[0])
      @titleEditable = new Tahi.PlaceholderElement($('#paper-title[contenteditable]')[0])

  savePaper: (e) ->
    e.preventDefault()
    $.ajax
      url: $(e.target).attr('href')
      method: "POST"
      data:
        _method: "patch"
        paper:
          title: @titleEditable.getText()
          body: @bodyEditable.getText()
          abstract: @abstractEditable.getText()
          short_title: @shortTitleEditable.getText()
          authors: (=> JSON.stringify @authorArray())()
    false

  updateAuthors: ->
    authors = Tahi.papers.authorArray()
    if authors.length > 0
      authorNames = authors.map (author) -> "#{author.first_name} #{author.last_name}"
      $('#paper-authors.editable').text authorNames.join(', ')
    else
      $('#paper-authors.editable').html '<span class="placeholder">Click here to add authors</span>'

  bindCloseToUpdateAuthors: ->
    $('.close-overlay').on 'click', =>
      @updateAuthors()

  initAuthors: ->
    @authors = @components.Authors
      authors: $('#paper-authors').data('authors')
    React.renderComponent @authors, document.getElementById('paper-authors')

  components:
    Authors: React.createClass
      getInitialState: ->
        authors: []

      componentWillMount: ->
        @setState authors: @props.authors

      render: ->
        if @state.authors.length > 0
          authorNames = @state.authors.map (author) ->
            "#{author.first_name} #{author.last_name}"
          `<span>{authorNames.join(', ')}</span>`
        else
          `<span className='placeholder'>Click here to add authors</span>`

      componentDidMount: ->
        @token = Tahi.pubsub.subscribe 'update_authors', (topic, authors) =>
          @setState authors: authors

      componentWillUnmount: ->
        Tahi.pubsub.unsubscribe @token
