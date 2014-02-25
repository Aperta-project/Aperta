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
      {div, h1, button, a} = React.DOM
      (div {},
        (h1 {}, "Would you like to post a task or a message?")
        (div {},
          (button {className: "btn-primary task"},"New Task Card"),
          (button {className: "btn-primary message"}, "New Message Card")
          (a {className: "cancel", onClick: @hideOverlay}, "Cancel")))
