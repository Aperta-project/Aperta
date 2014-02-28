window.Tahi ||= {}
Tahi.overlays ||= {}

Tahi.overlays.newMessage =
  overlay: React.createClass
    getDefaultProps: ->
      {chosenOptions: [[1, "First option"],[2, "Another"]]}

    chosenOptions: ->
      chosenOptions = [['', 'Add People']].concat @props.chosenOptions
      _.map chosenOptions, ([value, label]) -> React.DOM.option({value: value}, label)

    createCard: ->
      @refs.form.submit()
    render: ->
      {div, button, footer, option, header, a, h2, main, ul, li, input, textarea, img, label} = React.DOM
      RailsForm = Tahi.overlays.components.RailsForm
      (div {id: 'new-message-overlay'},
        (header {},
          (h2 {},
            (a {href: "#", className: 'message-color'}, @props.paperTitle))),
        (main {},
          (RailsForm {action: "/papers/#{@props.paperId}/messages.json", ref: 'form', method: 'POST', ajaxSuccess: Tahi.overlay.hide},
            (div {id: 'participants'},
              (ul {},
                (li {className: 'participant', "data-participant-name": "No Name"},
                  (img {src: "/images/profile-no-image.jpg"}))
                (li {},
                  (label {htmlFor: 'message-participants-chosen'}, 'Participants'),
                  (Chosen {width: '150px', id: "message-participants-chosen", name: 'task[participant_ids][]'},
                    @chosenOptions() )))),
            (div {className: 'form-group'},
              (input {id: 'message-subject', name: 'task[message_subject]', type: 'text', placeholder: 'Type in a subject here'})),
            (input {type: 'hidden', name: 'phase_id', value: @props.phaseId}),
            (div {className: 'form-group'},
              (textarea {id: 'message-body', name: 'task[message_body]', placeholder: 'Type your message here'}))
          ))
        (footer {},
          (div {className: "content"},
            (a {href: "#", className: 'message-color', onClick: Tahi.overlay.hide}, "Cancel")),
          (button {className: "primary-button message", onClick: @createCard}, "Create Card")))


