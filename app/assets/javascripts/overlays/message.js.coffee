Tahi.overlays.message =
  Overlay: React.createClass
    displayName: "MessageOverlay"
    mixins: [Tahi.mixins.MessageParticipants]
    componentWillMount: ->
      @setState @props

    getInitialState: ->
      userModels: [Tahi.currentUser]
      participants: []

    render: ->
      {h1, div, ul, li, label} = React.DOM
      (div {className: 'message-overlay'},
        (h1 {}, @state.messageSubject),
        (div {id: 'participants'},
          (ul {},
            (@renderParticipants()),
            (li {},
              (label {className: "hidden", htmlFor: 'message_participants_chosen'}, 'Participants'),
              (Chosen {"data-placeholder": "Add People", width: '150px', id: "message_participants_chosen", onChange: @addParticipant},
                @chosenOptions() )))))
