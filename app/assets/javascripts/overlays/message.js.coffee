Tahi.overlays.message =
  Overlay: React.createClass
    displayName: "MessageOverlay"
    mixins: [Tahi.mixins.MessageParticipants]

    componentWillMount: ->
      {participants, comments} = @props
      @mergeAssigneesToComments(participants, comments)
      @setState @props

    mergeAssigneesToComments: (participants, comments)->
      _(comments).each (comment)->
        match = _(participants).find (participant)->
          participant.id == comment.commenterId
        comment.name = match.fullName
        comment.avatar = match.imageUrl

    refreshComments: (e, data) ->
      newComments = @state.comments.concat(data.comment)
      newParticipants = @state.participants.concat(Tahi.currentUser)
      newParticipants = _.uniq newParticipants, (p) ->
        p.id

      @mergeAssigneesToComments(newParticipants, newComments)
      @setState({participants: newParticipants, comments: newComments})
      @clearMessageContent()

    getInitialState: ->
      userModels: [Tahi.currentUser]
      participants: []

    postMessage: (e)->
      @refs.form.submit()

    clearMessageContent: ->
      @refs.body.getDOMNode().value = null

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
              (span {className: "comment-date"}, $.timeago(comment.createdAt)),
              (span {className: "comment-name"}, "#{comment.name} posted"),
              (div  {className: "comment-body"}, comment.body))),
        (RailsForm {action: "/papers/#{@props.paperId}/tasks/#{@props.taskId}/comments.json", ref: 'form', method: 'POST', datatype: 'json', ajaxSuccess: @refreshComments},
          (input {type: 'hidden', name: 'comment[commenter_id]', value: Tahi.currentUser.id}),
          (div {className: 'form-group'},
            (textarea {ref: 'body', id: 'message-body', name: 'comment[body]', placeholder: 'Type your message here'}))),
        (div {className: "content"},
          (a {href: "#", className: 'message-color', onClick: @clearMessageContent}, "Cancel")),
        (button {className: "primary-button message", onClick: @postMessage}, "Post Message"))
