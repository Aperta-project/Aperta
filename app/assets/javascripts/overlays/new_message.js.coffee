Tahi.overlays.newMessage =
  overlay: React.createClass
    componentDidMount: ->
      $.getJSON '/users/chosen_options', (data) =>
        @setState userModels: data.users

    getInitialState: ->
      participants: [Tahi.currentUser]
      userModels: [Tahi.currentUser]

    chosenParticipants: ->
      _.map @selectableUsers(), (p) ->
        [p.id, p.fullName]


    selectableUsers: ->
      pIds = @participantIds()
      _.reject @state.userModels, (u) ->
        _.contains pIds, u.id

    renderParticipants: ->
      {UserThumbnail} = Tahi.overlays.components
      {li} = React.DOM
      _.map @state.participants, (p) ->
        (li {className: 'participant'},
          (UserThumbnail {name: p.fullName}))

    participantIds: ->
      _.pluck @state.participants, 'id'

    chosenOptions: ->
      chosenOptions = [['', '']].concat(@chosenParticipants())
      _.map chosenOptions, ([value, label]) -> React.DOM.option({value: value}, label)

    createCard: ->
      @refs.form.submit()

    addParticipant:(e) ->
      newParticipant = _.findWhere @state.userModels, {id: parseInt(e.target.value)}
      @setState participants: (@state.participants.concat(newParticipant))

    render: ->
      {div, button, footer, option, header, a, h2, main, ul, li, input, textarea, img, label} = React.DOM
      {RailsForm} = Tahi.overlays.components
      (div {id: 'new-message-overlay'},
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
            (input {ref: 'participants', type: 'hidden', name: 'task[participant_ids][]', value: @participantIds()}),
            (div {className: 'form-group'},
              (textarea {id: 'message-body', name: 'task[message_body]', placeholder: 'Type your message here'}))
          ))
        (footer {},
          (div {className: "content"},
            (a {href: "#", className: 'message-color', onClick: Tahi.overlay.hide}, "Cancel")),
          (button {className: "primary-button message", onClick: @createCard}, "Create Card")))


