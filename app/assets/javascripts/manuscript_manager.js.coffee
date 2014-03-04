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
        "Add New Card"
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

Tahi.manuscriptManager =
  init: ()->
    if columns = document.getElementById('manuscript-manager')
      columns = Tahi.manuscriptManager.Columns flows: [], route: columns.getAttribute("data-url")
      React.renderComponent columns, document.getElementById('tahi-container')

      $(document).on 'dragend', 'li.column', (e) ->
        # debugger
        columns.move(window.elementBeingDragged, e.targetPosition)

  Columns: React.createClass
    displayName: "Columns"

    move: (card, destination) ->
      currentFlows = _.clone(@state.flows)
      cardTitle = $(card).text()

      draggedTask

      for flow in currentFlows
        draggedTask = _.find flow.tasks, (task) ->
          task.taskTitle == cardTitle
        if draggedTask?
          flow.tasks.splice(flow.tasks.indexOf(draggedTask), 1)
          break

      @setState
        flows: currentFlows
        paper: @state.paper

      # pop the card being dragged from flows
      # card = current_flows.pop_card(card)
      # # push the card into its new place
      # current_flows.push_card(card, destination)
      # @setState flows: current_flows

    componentWillMount: ->
      @setState @props

    componentDidMount: ->
      Tahi.utils.bindColumnResize()

      $.getJSON @props.route, (data,status) =>
        @setState flows: data.flows, paper: data.paper

    componentDidUpdate: ->
      Tahi.utils.resizeColumnHeaders()

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

    removeCard: (taskId, phaseId) ->
      $.ajax
        url: 'tasks/' + taskId
        method: 'DELETE'
        success: =>
          newFlows = @state.flows.slice(0)
          flow = _.findWhere(newFlows, {id: phaseId})
          flow.tasks = _.reject flow.tasks, (task) ->
            task.taskId == taskId
          @setState flows: newFlows

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
          Tahi.manuscriptManager.ColumnAppender {
            addFunction: @addColumn
            bonusClass: 'first-add-column'
            index: 0}
          for flow, index in @state.flows
            Tahi.manuscriptManager.Column {
              addFunction: @addColumn,
              index: index+1,
              title: flow.title
              tasks: flow.tasks,
              phase_id: flow.id,
              paper: @state.paper
              removeCard: @removeCard
            }
      ))

  Column: React.createClass
    displayName: "Column"

    manuscriptCards: ->
      {li} = React.DOM
      cards = _.map @props.tasks, (task) =>
        (li {}, Tahi.manuscriptManager.Card {task: task, removeCard: => @props.removeCard(task.taskId, @props.phase_id)})
      cards.concat((li {},
        NewCardButton {
          paper: @props.paper,
          phase_id: @props.phase_id
      }))


    render: ->
      {h2, div, ul, li} = React.DOM
      (li {className: 'column'},
        Tahi.manuscriptManager.ColumnAppender {
          addFunction: @props.addFunction,
          index: @props.index}
        (h2 {}, @props.title),
        (div {className: 'column-content'},
          (ul {className: 'cards'},
            @manuscriptCards()
      )))

  ColumnAppender: React.createClass
    displayName: "ColumnAppender"
    handleClick: ->
      @props.addFunction(@props.index)

    render: ->
      @props.bonusClass ||= ""
      {span, i} = React.DOM
      (span {
        className: "add-column #{@props.bonusClass}",
        "data-toggle": "tooltip",
        "data-placement": "auto right",
        "title": "Add Phase"
        onClick: @handleClick},
        (i {className: 'glyphicon glyphicon-plus'}))

    componentDidMount: ->
      $(@getDOMNode()).tooltip()

  Card: React.createClass
    displayName: "Card"

    getInitialState: ->
      dragging: false

    dragStart: (e) ->
      window.elementBeingDragged = $(e.nativeEvent.target).parent('li')[0]
      @setState
        dragging: true

    dragEnd: (e) ->
      @setState
        dragging: false

    onDrag: (e) ->
      console.log "On Drag event: ", e

    cardClass: ->
      Tahi.className
        'card': true
        'completed': @props.task.taskCompleted
        'message': (@props.task.cardName == 'message')

    componentDidMount: ->
      $(@getDOMNode().querySelector('.js-remove-card')).tooltip()

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
          href: @props.task.taskPath,
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
          onClick: @props.removeCard })
      )

    displayCard: (event) ->
      Tahi.overlay.display event, @props.task.cardName
