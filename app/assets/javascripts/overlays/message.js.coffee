Tahi.overlays.message =
  Overlay: React.createClass
    displayName: "MessageOverlay"
    mixins: [Tahi.mixins.MessageParticipants]
    componentWillMount: ->
      @mergeAssigneesToComments()
      @setState @props

    mergeAssigneesToComments: ->
      {assignees, comments} = @props
      _(comments).each (comment)->
         match = _(assignees).find (assignee)->
           assignee.id == comment.commenter_id
         comment.name = match.full_name
         comment.avatar = match.avatar

    getInitialState: ->
      userModels: [Tahi.currentUser]
      participants: []

    render: ->
      {main, h1, div, ul, li, label, span} = React.DOM
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
            (li {},
              (Tahi.overlays.components.UserThumbnail {className: 'user-thumbnail comment-avatar', imgSrc: comment.avatar, name: comment.name}),
              (span {className: "comment-date"}, $.timeago(comment.created_at.split('T')[0]))
              (span {className: "comment-name"}, "#{comment.name} posted")
              (div  {className: "comment-body"}, comment.body))))
