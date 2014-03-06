Tahi.mixins.MessageParticipants =
  componentDidMount: ->
    $.getJSON '/users/chosen_options', (data) =>
      @setState userModels: data.users

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

  addParticipantCallback: (e) ->
    @addParticipant(parseInt(e.target.value))

  addParticipant:(id) ->
    newParticipant = _.findWhere @state.userModels, {id: id}
    @setState participants: (@state.participants.concat(newParticipant))
