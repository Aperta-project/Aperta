window.Tahi ||= {}

Card = React.createClass
  cardClass: ->
    Tahi.className
      'card': true
      'flow-card':  @props.flowCard
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

PaperProfile = React.createClass
  render: ->
    {div, h4, a} = React.DOM

    (div {className: 'paper-profile'}, [
      (a {href: @props.profile.paper_path, className: 'paper-title'},
        (h4 {}, @props.profile.title)),

      for task in @props.profile.tasks
        (Card {task: task, flowCard: true})])

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

Column = React.createClass
  manuscriptCards: ->
    {li} = React.DOM
    cards = for task in @props.tasks
      (li {}, Card {task: task})
    cards.concat((li {},
      NewCardButton {
        paper: @props.paper,
        phase_id: @props.phase_id
    }))

  paperProfiles: ->
    {li} = React.DOM
    for paperProfile in @props.paperProfiles
      (li {}, PaperProfile {profile: paperProfile})

  render: ->
    {h2, ul, li, div, li} = React.DOM

    (li {className: 'column'},
      (h2 {}, @props.title),
      (div {className: 'column-content'},
        (ul {className: 'cards'},
          if @props.tasks
            @manuscriptCards()
          else
            @paperProfiles()
    )))

MrManager = React.createClass
  componentDidMount: ->
    $.getJSON @props.route, (data,status) =>
      @setProps flows: data.flows, paper: data.paper

  componentDidUpdate: ->
    $('.paper-profile h4').dotdotdot
      height: 40

  render: ->
    {ul, div} = React.DOM
    if @props.paper
      header = ManuscriptHeader {paper: @props.paper}
    (div {},
        header
      (ul {className: 'columns'},
        for flow, index in @props.flows
          Column {
            key: "flow-#{index}",
            paperProfiles: flow.paperProfiles,
            title: flow.title
            tasks: flow.tasks,
            phase_id: flow.id,
            paper: @props.paper
          }
    ))

Tahi.mrManager =
  init: ()->
    if mrManager = document.getElementById('mr-manager')
      manuscriptManager = MrManager flows: [], route: mrManager.getAttribute("data-url")
      React.renderComponent manuscriptManager, document.getElementById('tahi-container')
