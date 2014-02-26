window.Tahi ||= {}
Tahi.overlays ||= {}

Tahi.overlays.newMessage =
  overlay: React.createClass
    componentDidMount: ->
      #TODO: get the list of names and ids from the server.
      @setProps {chosenOptions: [[1, "First option"],[2, "Another"]]}

    chosenOptions: ->
      chosenOptions = ['', 'Add People'].concat @props.chosenOptions
      _.map chosenOptions, ([value, label]) -> React.DOM.option({value: value}, label)

    render: ->
      {div, button, footer, option, header, a, h2, main, ul, li, input, textarea, img} = React.DOM
      RailsForm = Tahi.overlays.components.RailsForm
      (div {id: 'new-message-overlay'},
        (header {},
          (h2 {},
            (a {href: "#", className: 'message-color'}, @props.paperTitle))),
        (main {},
          (RailsForm {action: "/papers/#{@props.paperId}/tasks.json", ref: 'form', method: 'POST'},
            (div {id: 'recipients'},
              (ul {},
                (li {},
                  (img {src: "/images/profile-no-image.jpg"}))
                (li {},
                  (Chosen {width: '150px'},
                    @chosenOptions() )))),
            (div {className: 'form-group'}, (input {type: 'text', placeholder: 'Type in a subject here'})),
            (div {className: 'form-group'},(textarea {placeholder: 'Type your message here'}))
          ))
        (footer {},
          (div {className: "content"},
            (a {href: "#", className: 'message-color', onClick: Tahi.overlay.hide}, "Cancel")),
          (button {className: "primary-button message", onClick: @createCard}, "Create Card")))


