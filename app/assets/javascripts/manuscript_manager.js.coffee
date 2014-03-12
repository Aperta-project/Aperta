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
    {ul, div, section, img, h2, li, a} = React.DOM
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
  init: ->
    if columns = document.getElementById('manuscript-manager')
      columns = Tahi.manuscriptManager.Columns flows: [], route: columns.getAttribute("data-url")
      React.renderComponent columns, document.getElementById('tahi-container')
      @setupDragListeners columns

  setupDragListeners: (columns) ->
    $(document).on 'dragover', 'li.column, li.column *', (e) ->
      e.preventDefault()
      e.stopPropagation()
      $(e.currentTarget.offsetParent).closest('.column').addClass 'drop-column'

    $(document).on 'dragleave', 'li.column', (e) ->
      e.preventDefault()
      e.stopPropagation()
      $(this).removeClass 'drop-column'

    $(document).on 'drop', 'li.column', (e) ->
      e.preventDefault()
      e.stopPropagation()
      $(this).removeClass 'drop-column'
      columns.move(Tahi.elementBeingDragged, this)
      Tahi.elementBeingDragged = null

  Columns: React.createClass
    displayName: "Columns"

    render: ->
      {ul, div} = React.DOM
      if @state.paper
        header = ManuscriptHeader {paper: @state.paper}
      (div {className: "full-height"},
        header
        (ul {className: 'columns'},
          Tahi.manuscriptManager.ColumnAppender {
            addFunction: @addColumn
            bonusClass: 'first-add-column'
            position: -1}
          for flow, position in @state.flows
            Tahi.manuscriptManager.Column {
              addFunction: @addColumn
              onRemove: @removeColumn
              updateName: @updateColumnName
              position: flow.position
              name: flow.name
              tasks: flow.tasks
              phase_id: flow.id
              paper: @state.paper
              removeCard: @removeCard
              onCompletedChanged: @onCompletedChanged
            }
      ))

    onCompletedChanged: (phaseId, taskId, completed) ->
      flows = @state.flows
      flow = _.find flows, (flow) ->
        flow.id == phaseId

      task = _.find flow.tasks, (task) ->
        task.taskId == taskId

      task.taskCompleted = completed
      @setState flows: flows

    popDraggedTask: (cardId) ->
      for flow in @state.flows
        draggedTask = _.find flow.tasks, (task) ->
          task.taskId == cardId
        if draggedTask?
          flow.tasks.splice(flow.tasks.indexOf(draggedTask), 1)
          return draggedTask

    pushDraggedTask: (task, destination) ->
      destinationFlow = _.find @state.flows, (flow) ->
        flow.id == parseInt $(destination).attr('data-phase-id')

      destinationFlow.tasks.push task
      destinationFlow

    syncTask: (draggedTask, destinationFlow) ->
      $.ajax
        url: "/papers/#{draggedTask.paperId}/tasks/#{draggedTask.taskId}"
        method: 'POST'
        data:
          _method: 'PUT'
          task:
            id: draggedTask.taskId
            phase_id: destinationFlow.id

    move: (card, destination) ->
      cardId = parseInt($(card).find('.card').attr 'data-task-id')
      draggedTask = @popDraggedTask cardId
      destinationFlow = @pushDraggedTask draggedTask, destination
      @syncTask draggedTask, destinationFlow
      @setState
        flows: @state.flows

    componentWillMount: ->
      @setState @props

    componentDidUpdate: ->
      Tahi.utils.resizeColumnHeaders()

    componentDidMount: ->
      Tahi.utils.bindColumnResize()
      @startPolling()
      @getColumns()

    getColumns: ->
      $.getJSON @props.route, (data,status) =>
        @setState flows: _.sortBy(data.flows, (f) -> f.position), paper: data.paper

    startPolling: ->
      setInterval((=> @getColumns()), 5000)

    componentDidUpdate: ->
      Tahi.utils.resizeColumnHeaders()

      $('.paper-profile h4').dotdotdot
        height: 40

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

    insertPhase: (newPhase) ->
      newPhase.paper = @state.paper
      newFlows = @state.flows.slice(0) #don't mutate old state
      [head, tail] =  _.partition newFlows, (flow) ->
        flow.position < newPhase.position
      _.map tail, (flow) ->
        flow.position += 1
      updatedFlows = head.concat newPhase, tail
      @setState flows: updatedFlows

    findPhase: (phase_id)->
      _(@state.flows).find (phase)-> phase.id == phase_id

    updateColumnName: (name, phase_id)->
      storedPhase = @findPhase(phase_id)
      if name != storedPhase.name
        $.ajax
          url: "/phases"
          method: 'PUT'
          data:
            id: phase_id
            phase:
              name: name
          success: (data)=>
            newFlows = @state.flows.slice(0)
            i = newFlows.indexOf storedPhase
            # data.phase.tasks are being sent from the server in a different
            # order, so use the same unchanged tasks to preserve order
            tasks = newFlows[i].tasks.slice(0)
            newFlows.splice(i, 1, data.phase)
            newFlows[i].tasks = tasks
            @setState flows: newFlows

    addColumn: (position) ->
      newPosition = position + 1
      column =
        paper: @state.paper
        tasks: []
        position: newPosition
        name: "New Phase"
      $.ajax
        url: '/phases'
        method: 'POST'
        dataType: 'json'
        data:
          phase:
            task_manager_id: @state.paper.task_manager_id
            position: newPosition
            name: column.name
        success: (data) => @insertPhase(data.phase)

    removeColumn: (phaseId) ->
      $.ajax
        url: "/phases"
        method: 'DELETE'
        dataType: 'json'
        data:
          id: phaseId
        success: =>
          newFlows = _(@state.flows.slice(0)).reject (flow)-> flow.id == phaseId
          @setState flows: newFlows

  Column: React.createClass
    displayName: "Column"
    render: ->
      {h2, div, ul, li, span, button} = React.DOM
      (li {className: 'column', 'data-phase-id': @props.phase_id },
        Tahi.manuscriptManager.ColumnAppender {
          addFunction: @props.addFunction,
          position: @props.position}
        (div {className: "column-title"},
          (h2 {
            onClick: @showButtons
            contentEditable: "true"},
            @props.name)

          (div {className: "column-header-update-buttons"},
            button {onClick: @cancelEdit, className: "column-header-update-cancel btn-link"},     "cancel"
            button {onClick: @updateName, className: "column-header-update-save primary-button"}, "Save")

          (span {className: "glyphicon glyphicon-pencil edit-icon column-icon"}, "")
          if !@props.tasks.length
            (span {className: "glyphicon glyphicon-remove remove-icon column-icon", onClick: @remove}, "")
        )
        (div {className: 'column-content'},
          (ul {className: 'cards'},
            @manuscriptCards()
      )))

    remove: ->
      @props.onRemove @props.phase_id

    cancelEdit: ->
      $(@getDOMNode()).find("h2").text(@props.name)
      @hideButtons()

    updateName: ->
      name = $(@getDOMNode()).find("h2").text()
      @props.updateName(name, @props.phase_id)
      @hideButtons()

    hideButtons: ->
      $(@getDOMNode()).find(".column-title").removeClass('active')

    showButtons: ->
      $(@getDOMNode()).find(".column-title").addClass('active')

    onCompletedChanged: (taskId, completed) ->
      @props.onCompletedChanged(@props.phase_id, taskId, completed)

    manuscriptCards: ->
      {li} = React.DOM
      cards = _.map @props.tasks, (task) =>
        (li {className: 'card-item'}, Tahi.columnComponents.Card {onCompletedChanged: @onCompletedChanged, task: task, removeCard: => @props.removeCard(task.taskId, @props.phase_id)})
      cards.concat((li {},
        NewCardButton {
          paper: @props.paper,
          phase_id: @props.phase_id
      }))

  ColumnAppender: React.createClass
    displayName: "ColumnAppender"
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

    handleClick: ->
      @props.addFunction(@props.position)

    componentDidMount: ->
      $(@getDOMNode()).tooltip()
