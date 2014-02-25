window.Tahi ||= {}
Tahi.overlays ||= {}

Tahi.overlays.chooseCardType =
  init: ->
    $('.react-choose-card-type-overlay').on 'click', Tahi.overlays.chooseCardType.displayOverlay

  displayOverlay: (e) =>
    e.preventDefault(e)
    React.renderComponent Tahi.overlays.chooseCardType.overlay({}), $('#overlay')[0]
    $('#overlay').show()

  overlay: React.createClass
    hideOverlay: (e) ->
      e?.preventDefault()
      $('#overlay').hide()
      React.unmountComponentAtNode document.getElementById('overlay')

    render: ->
      {div, h2, button, a} = React.DOM
      (div {className: 'choose-card-type-overlay'},
        (div {id: 'choose-card-type'},
          (h2 {}, "Would you like to post a task or a message?")
          (div {id: 'choose-card-type-buttons'},
            (button {className: "primary-button task"},"New Task Card"),
            (button {className: "primary-button message"}, "New Message Card")
            (a {href: "#", className: "cancel", onClick: @hideOverlay}, "Cancel"))))
