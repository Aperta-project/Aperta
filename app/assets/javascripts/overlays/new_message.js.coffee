Tahi.overlays.newMessage =
  overlay: React.createClass
    mixins: [Tahi.mixins.MessageParticipants]

    getInitialState: ->
      participants: [Tahi.currentUser]
      userModels: [Tahi.currentUser]

    createCard: ->
      @refs.form.submit()

    render: ->
      {div, button, footer, option, header, a, h2, main, ul, li, input, textarea, img, label} = React.DOM
      {RailsForm} = Tahi.overlays.components
      (div {id: 'new-message-overlay', className: 'message-overlay'},
        (header {},
          (h2 {},
            (a {href: "#", className: 'message-color'}, @props.paperTitle))),
        (main {},
          (RailsForm {action: "/papers/#{@props.paperId}/messages.json", ref: 'form', method: 'POST', ajaxSuccess: Tahi.overlay.hide},
            (div {id: 'participants'},
              (ul {},
                (@renderParticipants()),
                (li {},
                  (label {className: "hidden", htmlFor: 'message_participants_chosen'}, 'Participants'),
                  (Chosen {"data-placeholder": "Add People", width: '150px', id: "message_participants_chosen", onChange: @addParticipant},
                    @chosenOptions() )))),
            (div {className: 'form-group'},
              (input {id: 'message-subject', name: 'task[message_subject]', type: 'text', placeholder: 'Type in a subject here'})),
            (input {type: 'hidden', name: 'phase_id', value: @props.phaseId}),
            (_.map @participantIds(), (p) ->
              (input {type: 'hidden', name: "task[participant_ids][]", value: p})),
            (div {className: 'form-group'},
              (textarea {id: 'message-body', name: 'task[message_body]', placeholder: 'Type your message here'}))
          ))
        (footer {},
          (div {className: "content"},
            (a {href: "#", className: 'message-color', onClick: Tahi.overlay.hide}, "Cancel")),
          (button {className: "primary-button message", onClick: @createCard}, "Create Card")))


