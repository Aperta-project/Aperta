window.Tahi ||= {}

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

ColumnAppender = React.createClass
  displayName: "ColumnAppender"
  handleClick: ->
    @props.addFunction(@props.index)

  render: ->
    {span, i} = React.DOM
    (span {className: 'addColumn', onClick: @handleClick},
      (i {className: 'glyphicon glyphicon-plus'}))

Tahi.manuscriptManager =
  init: ()->
    if columns = document.getElementById('manuscript-manager')
      columns = Tahi.manuscriptManager.Columns flows: [], route: columns.getAttribute("data-url")
      React.renderComponent columns, document.getElementById('tahi-container')

  Columns: React.createClass
    displayName: "Columns"
    componentWillMount: ->
      @setState @props

    componentDidMount: ->
      $.getJSON @props.route, (data,status) =>
        @setState flows: data.flows, paper: data.paper

    componentDidUpdate: ->
      $('.paper-profile h4').dotdotdot
        height: 40

    calculateFlowIndices: ->
      i = 0
      _(@state.flows).map (flow)->
        flow.position = i++

    setFlowIndices: ->
      $.ajax
        url: '/phases'
        method: 'PUT'
        dataType: 'json'
        data:
          task_manager_id: @state.paper.task_manager_id
          flows: _(@state.flows).map (flow)->
            {id: flow.id, position: flow.position}
        success: (data)=>
          @setState flows: @state.flows

    addColumn: (index) ->
      column = {
        key: "flow-1",
        paper: @state.paper
        tasks: []
        paperProfiles: []
      }
      @state.flows.splice(index, 0, column)
      @calculateFlowIndices()
      $.ajax
        url: '/phases'
        method: 'POST'
        dataType: 'json'
        data:
          task_manager_id: @state.paper.task_manager_id
        success: (data)=>
          column.id = data.id
          column.title = data.name
          @setFlowIndices()

    render: ->
      {ul, div} = React.DOM
      if @state.paper
        header = ManuscriptHeader {paper: @state.paper}
      (div {},
          header
        (ul {className: 'columns'},
          for flow, index in @state.flows.concat("hack")
            (ColumnAppender {
              addFunction: @addColumn,
              index: index,
              className: 'add-column'})
          for flow, index in @state.flows
            Tahi.manuscriptManager.Column {
              addFunction: @addColumn,
              index: index+1,
              title: flow.title
              tasks: flow.tasks,
              phase_id: flow.id,
              paper: @state.paper
            }
      ))

  Column: React.createClass
    displayName: "Column"
    manuscriptCards: ->
      {li} = React.DOM
      cards = for task in @props.tasks
        (li {}, Tahi.manuscriptManager.Card {task: task})
      cards.concat((li {},
        NewCardButton {
          paper: @props.paper,
          phase_id: @props.phase_id
      }))

    render: ->
      {h2, div, ul, li} = React.DOM


      (li {className: 'column'},
        (h2 {}, @props.title),
        (div {className: 'column-content'},
          (ul {className: 'cards'},
            @manuscriptCards()
      )))

  Card: React.createClass
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

