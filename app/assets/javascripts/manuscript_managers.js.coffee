window.Tahi ||= {}

Card = React.createClass
  cardClass: ->
    Tahi.className
      'card': true
      'flow-card': true
      'completed': @props.task.taskCompleted

  render: ->
    {a, span} = React.DOM
    (a {
        className: @cardClass(),
        onClick: @displayCard,
        "data-card-name": @props.task.cardName,
        "data-task-id":   @props.task.taskId,
        "data-task-path": @props.task.taskPath,
        href: @props.task.taskPath
      },
      (span {className: 'glyphicon glyphicon-ok'}),
      @props.task.taskTitle
    )

  displayCard: (event) ->
    Tahi.overlay.display event, @props.task.cardName

PaperProfile = React.createClass
  render: ->
    {div, h4, a} = React.DOM

    (div {className: 'paper-profile'}, [
      (a {href: @props.profile.paper_path, className: 'paper-title'},
        (h4 {}, @props.profile.title)),

      for task in @props.profile.tasks
        (Card {task: task})])

Phase = React.createClass
  render: ->
    {h2, ul, li, div, li} = React.DOM

    (li {className: 'column phase'},
      (div {className: 'phase-container'},
        (h2 {}, @props.name)),
      (ul {className: 'cards'},
        # for card in @props.tasks
        #   (li {}, Task {task: task})
      ))

ManuscriptManager = React.createClass
  componentDidMount: ->
    $.getJSON @props.route, (data,status) =>
      @setProps phases: data.phases, paper: data.paper

  componentDidUpdate: ->
    $('.paper-profile h4').dotdotdot
      height: 40

  render: ->
    {ul} = React.DOM
    (ul {className: 'columns phases'},
      for phase, index in @props.phases
        Phase {key: "flow-#{index}", tasks: phase.tasks, name: phase.name}
    )

Tahi.manuscriptManager =
  init: (route, container)->
    if document.getElementById('manuscript-manager')
      manuscriptManager = ManuscriptManager phases: [], route: route
      React.renderComponent manuscriptManager, container || document.getElementById('tahi-container')
