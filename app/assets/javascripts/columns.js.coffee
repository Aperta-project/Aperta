window.Tahi ||= {}

Card = React.createClass
  displayName: "Card"
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
  displayName: "NewCardButton"
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
  displayName: "PaperProfile"
  render: ->
    {div, h4, a} = React.DOM

    (div {className: 'paper-profile'}, [
      (a {href: @props.profile.paper_path, className: 'paper-title'},
        (h4 {}, @props.profile.title)),

      for task in @props.profile.tasks
        (Card {task: task, flowCard: true})])

ManuscriptHeader = React.createClass
  displayName: "ManuscriptHeader"
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
  displayName: "Column"
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
    {h2, ul, li, div, span} = React.DOM

    (li {className: 'column'},
      (ColumnAppender {
            addFunction: @props.addFunction,
            index: @props.index,
            className: 'add-column'}),
      (h2 {}, @props.title),
      (div {className: 'column-content'},
        (ul {className: 'cards'},
          if @props.tasks
            @manuscriptCards()
          else
            @paperProfiles()
    )))

ColumnAppender = React.createClass
  displayName: "ColumnAppender"
  handleClick: ->
    @props.addFunction(@props.index)

  render: ->
    {span, i} = React.DOM
    (span {className: 'addColumn', onClick: @handleClick},
      (i {className: 'glyphicon glyphicon-plus'}))

Columns = React.createClass
  displayName: "Columns"
  componentDidMount: ->
    $.getJSON @props.route, (data,status) =>
      @setProps flows: data.flows, paper: data.paper

  componentDidUpdate: ->
    $('.paper-profile h4').dotdotdot
      height: 40

  addColumn: (index) ->
    column = {
      key: "flow-1",
      title: "new title",
      paper: @props.paper
      tasks: []
      paperProfiles: []
    }
    @props.flows.splice(index, 0, column)
    # do some jquery 
    $.ajax
      url: '/phases'
      method: 'POST'
      dataType: 'json'
      data:
        task_manager_id: @props.paper.task_manager_id
        position: index
      success: (data)=>
        column.phase_id = data.id
        column.title = data.name

    @setProps flows: @props.flows

  render: ->
    {ul, div} = React.DOM
    if @props.paper
      header = ManuscriptHeader {paper: @props.paper}
    (div {},
        header
      (ul {className: 'columns'},
        for flow, index in @props.flows
          (Column {
            key: "flow-#{index}",
            addFunction: @addColumn,
            index: index+1,
            paperProfiles: flow.paperProfiles,
            title: flow.title
            tasks: flow.tasks,
            phase_id: flow.id,
            paper: @props.paper
          })
    ))

Tahi.Columns =
  init: ()->
    if columns = document.getElementById('column-manager')
      columns = Columns flows: [], route: columns.getAttribute("data-url")
      React.renderComponent columns, document.getElementById('tahi-container')
