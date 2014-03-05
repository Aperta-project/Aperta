Tahi.overlays.message =
  Overlay: React.createClass
    displayName: "MessageOverlay"
    mixins: [Tahi.mixins.MessageParticipants]

    componentWillMount: ->
      @mergeAssigneesToComments()
      @setState @props

    mergeAssigneesToComments: ->
      {participants, comments} = @props
      _(comments).each (comment)->
        match = _(participants).find (participant)->
          participant.id == comment.commenter_id
        comment.name = match.fullName
        comment.avatar = match.image_url

    refreshComments: (data) ->

    getInitialState: ->
      userModels: [Tahi.currentUser]
      participants: []

    postMessage: ->
      @refs.form.submit()

    render: ->
      {RailsForm, UserThumbnail} = Tahi.overlays.components
      {main, h1, div, ul, li, label, span, input, textarea, a, button} = React.DOM
      (main {className: 'message-overlay'},
        (h1 {}, @state.messageSubject),
        (div {id: 'participants'},
          (ul {},
            (@renderParticipants()),
            (li {},
              (label {className: "hidden", htmlFor: 'message_participants_chosen'}, 'Participants'),
              (Chosen {"data-placeholder": "Add People", width: '150px', id: "message_participants_chosen", onChange: @addParticipant},
                @chosenOptions() )))),
        (ul {className: "message-comments"},
          _.map @state.comments, (comment)->
            (li {className: "message-comment"},
              (UserThumbnail {className: 'user-thumbnail comment-avatar', imgSrc: comment.avatar, name: comment.name}),
              (span {className: "comment-date"}, $.timeago(comment.created_at.split('T')[0]))
              (span {className: "comment-name"}, "#{comment.name} posted")
              (div  {className: "comment-body"}, comment.body))),
        (RailsForm {action: "/papers/#{@props.paperId}/tasks/#{@props.taskId}/comments.json", ref: 'form', method: 'POST', ajaxSuccess: @refreshComments},
          (input {type: 'hidden', name: 'task[commentor_id]', value: Tahi.currentUser.id}),
          (div {className: 'form-group'},
            (textarea {id: 'message-body', name: 'task[message_body]', placeholder: 'Type your message here'}))),
        (div {className: "content"},
          (a {href: "#", className: 'message-color', onClick: @clearMessageContent}, "Cancel")),
        (button {className: "primary-button message", onClick: @postMessage}, "Post Message"))
