Tahi.columnComponents.Card = React.createClass
  displayName: "Card"
  cardClass: ->
    Tahi.className
      'card': true
      'flow-card':  @props.flowCard
      'completed': @props.task.taskCompleted
      'message': (@props.task.cardName == 'message')

  componentDidMount: ->
    $(@getDOMNode().querySelector('.js-remove-card')).tooltip()

  render: ->
    {div, a, span} = React.DOM
    (div {className: "card-container"},
      (a {
        className: @cardClass(),
        onClick: @displayCard,
        "data-card-name": @props.task.cardName,
        "data-task-id":   @props.task.taskId,
        "data-task-path": @props.task.taskPath,
        href: @props.task.taskPath
      },
        (span {className: 'glyphicon glyphicon-ok completed-glyph'}),
          @props.task.taskTitle
      ),
      (span {
        className: 'glyphicon glyphicon-remove-circle remove-card js-remove-card pointer',
        "data-toggle": "tooltip",
        "data-placement": "right",
        "title": "Delete Card",
        onClick: @props.removeCard })
    )

