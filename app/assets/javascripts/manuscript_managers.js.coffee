window.Tahi ||= {}

Task = React.createClass
  cardClass: ->
    Tahi.className
      'card': true
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

NewCardButton = React.createClass
  render: ->
    {a} = React.DOM
    (a
      className: 'secondary-button react-choose-card-type-overlay',
      "data-assignees": JSON.stringify(@props.paper.assignees),
      "data-url": @props.paper.tasks_url,
      "data-phase_id": @props.phase_id,
      "data-paper_id": @props.paper.id,
      "data-paper_title": @props.paper.paper_short_title,
      href: "#",
        "ADD NEW CARD"
    )

Phase = React.createClass
  render: ->
    {h2, ul, li, div, li} = React.DOM

    (li {className: 'column phase'},
      (div {className: 'phase-container'},
        (h2 {}, @props.name)),
      (ul {className: 'cards'},
        for task in @props.tasks
          (li {}, Task {task: task})
        (li {},
          NewCardButton {
            paper: @props.paper,
            phase_id: @props.phase_id
          }),
      ))

ManuscriptHeader = React.createClass
  render: ->
    {ul, div, section, img, h2, li, a, section} = React.DOM
    (div {id:'control-bar-container'},
      div {id:'control-bar'},
        section {},
          ul {},
            li {id:'paper-journal'},
              if @props.paper.journal_logo_url
                img {src: @props.paper.journal_logo_url}
              else
                div {}, @props.paper.journal_name
            li {id:'paper-short-title'},
              h2 {className:'tasks-paper-title'}, @props.paper.paper_short_title
          ul {},
            li {},
              a {href:@props.paper.edit_url}, "Manuscript")

ManuscriptManager = React.createClass
  componentDidMount: ->
    $.getJSON @props.route, (data,status) =>
      @setProps phases: data.phases, paper: data.paper

  componentDidUpdate: ->
    $('.paper-profile h4').dotdotdot
      height: 40

  render: ->
    {ul, div} = React.DOM
    (div {},
      if @props.paper
        ManuscriptHeader {paper: @props.paper}
      (ul {className: 'columns phases'},
        for phase, index in @props.phases
          Phase {
            tasks: phase.tasks,
            name: phase.name,
            phase_id: phase.id,
            paper: @props.paper
          }
    ))

Tahi.manuscriptManager =
  init: (route, container)->
    if document.getElementById('manuscript-manager')
      manuscriptManager = ManuscriptManager phases: [], route: route || location.href
      React.renderComponent manuscriptManager, container || document.getElementById('tahi-container')
