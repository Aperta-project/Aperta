window.Tahi ||= {}
Tahi.overlays ||= {}

Tahi.overlays.newMessage =
  overlay: React.createClass
    render: ->
      RailsForm = Tahi.overlays.components.RailsForm
      {div, button, footer, header, a, h2, main, ul, li, input, textarea} = React.DOM
      (div {},
        (header {},
          (h2 {},
          (a {href: "#"}, "Paper Title"))),
        (main {},
          (RailsForm {action: '', ref: 'form'},
            (div {id: 'recipients'},
              (ul {},
                (li {}, "Person 1 avatar")),
              (Chosen {}, '')),
            (input {type: 'text', placeholder: 'Type in a subject here'}),
            (textarea {placeholder: 'Type in a subject here'})))
        (footer {},
          (div {className: "content"},
            (a {href: "#"}, "Cancel")),
          (button {className: "primary-button message"}, "Create Card")))


