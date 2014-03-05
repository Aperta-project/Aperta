Tahi.overlays.chooseCardType =
  init: ->
    $(document).on 'click', '.react-choose-card-type-overlay', Tahi.overlays.chooseCardType.displayOverlay

  displayOverlay: (e) =>
    e.preventDefault(e)
    data = $(e.target).data()
    cardData =
      assignees: data.assignees
      url: data.url
      phaseId: data.phase_id
      paperId: data.paper_id
      paperShortTitle: data.paper_title
    React.renderComponent Tahi.overlays.chooseCardType.overlay(cardData), $('#overlay')[0]
    $('html').addClass 'noscroll'
    $('#overlay').show()


  overlay: React.createClass
    displayName: "ChooseCardType"
    render: ->
      {div, h2, button, a} = React.DOM
      (div {className: 'choose-card-type-overlay'},
        (div {id: 'choose-card-type'},
          (h2 {}, "Would you like to post a task or a message?")
          (div {id: 'choose-card-type-buttons'},
            (button {className: "primary-button task", onClick: @replaceTaskOverlay}, "New Task Card"),
            (button {className: "primary-button message", onClick: @replaceMessageOverlay}, "New Message Card")
            (a {href: "#", className: "cancel", onClick: Tahi.overlay.hide}, "Cancel"))))

    replaceTaskOverlay: (e) ->
      e?.preventDefault()
      React.unmountComponentAtNode $('#overlay')[0]
      React.renderComponent Tahi.overlays.newCard.components.NewCardOverlay(@props), $('#overlay')[0]

    replaceMessageOverlay: (e) ->
      e?.preventDefault()
      React.unmountComponentAtNode $('#overlay')[0]
      React.renderComponent Tahi.overlays.newMessage.overlay(@props), $('#overlay')[0]

