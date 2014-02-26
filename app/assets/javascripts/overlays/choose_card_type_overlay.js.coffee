window.Tahi ||= {}
Tahi.overlays ||= {}

Tahi.overlays.chooseCardType =
  init: ->
    $(document).on 'click', '.react-choose-card-type-overlay', Tahi.overlays.chooseCardType.displayOverlay

  displayOverlay: (e) =>
    e.preventDefault(e)
    React.renderComponent Tahi.overlays.chooseCardType.overlay($(e.target).data()), $('#overlay')[0]
    $('#overlay').show()


  overlay: React.createClass
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

