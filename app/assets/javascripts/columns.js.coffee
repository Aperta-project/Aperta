Tahi.columnComponents.Card = React.createClass
  displayName: "Card"

  getInitialState: ->
    dragging: false

  dragStart: (e) ->
    Tahi.elementBeingDragged = $(e.nativeEvent.target).closest('li.card-item')[0]

    e.nativeEvent.dataTransfer.effectAllowed = "move"

    # This is needed to make divs draggable in Firefox.
    # http://html5doctor.com/native-drag-and-drop/
    #
    e.nativeEvent.dataTransfer.setData 'text', 'drag'

    @setState
      dragging: true

  dragEnd: (e) ->
    @setState
      dragging: false

  cardClass: ->
    Tahi.className
      'card': true
      'flow-card':  @props.flowCard
      'completed': @props.task.taskCompleted
      'message': (@props.task.cardName == 'message')

  componentDidMount: ->
    $(@getDOMNode().querySelector('.js-remove-card')).tooltip()

  displayCard: (event) ->
    event.preventDefault()
    cardName = Tahi.utils.toCamel @props.task.cardName
    overlayProps =
      cardName: cardName
      taskId: @props.task.taskId
      taskPath: @props.task.taskPath
      onCompletedChanged: @onCompletedChanged
      componentToRender: Tahi.overlays[cardName].Overlay

    Tahi.overlay.renderComponent event, overlayProps

  onCompletedChanged: (completed) ->
    @props.onCompletedChanged @props.task.taskId, completed

  render: ->
    {div, a, span} = React.DOM
    (div {className: "card-container"},
      (a {
        className: @cardClass(),
        onDragStart: @dragStart,
        onDragEnd: @dragEnd,
        onClick: @displayCard,
        "data-card-name": @props.task.cardName,
        "data-task-id":   @props.task.taskId,
        "data-task-path": @props.task.taskPath,
        draggable: true
      },
        (span {className: 'glyphicon glyphicon-ok completed-glyph'}),
          @props.task.taskTitle
      ),
      (span {
        className: 'glyphicon glyphicon-remove-circle remove-card js-remove-card pointer',
        "data-toggle": "tooltip",
        "data-placement": "right",
        "title": "Delete Card",
        onClick: @props.removeCard }))


