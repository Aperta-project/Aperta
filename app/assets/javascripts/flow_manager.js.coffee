window.Tahi ||= {}

Tahi.flowManager =
  init: ()->
    if columns = document.getElementById('flow-manager')
      columns = Tahi.flowManager.Columns flows: [], route: columns.getAttribute("data-url")
      React.renderComponent columns, document.getElementById('tahi-container')

  Columns: React.createClass
    displayName: "Columns"
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

    removeFlow: (title) ->
      @setState {flows: _.reject(@state.flows, (flow) -> flow.title == title)}, @saveFlows

    saveFlows: ->
      flowTitles = _.map @state.flows, (flow) -> flow.title
      $.post 'user_settings',
        _method: 'PATCH'
        user_settings:
          flows: flowTitles

    render: ->
      {ul, div} = React.DOM
      if @state.paper
        header = ManuscriptHeader {paper: @state.paper}
      (div {},
          header
        (ul {className: 'columns'},
          for flow, index in @state.flows
            Tahi.flowManager.Column {
              key: "flow-#{index}",
              addFunction: @addColumn,
              index: index+1,
              paperProfiles: flow.paperProfiles,
              title: flow.title
              tasks: flow.tasks,
              phase_id: flow.id,
              paper: @state.paper
              onRemove: @removeFlow
            }
      ))

  Column: React.createClass
    displayName: "Column"

    paperProfiles: ->
      {li} = React.DOM
      for paperProfile in @props.paperProfiles
        (li {}, Tahi.flowManager.PaperProfile {profile: paperProfile})

    remove: ->
      @props.onRemove @props.title

    render: ->
      {h2, div, ul, li} = React.DOM

      closeButton = ' '
      closeButton = (div {className: 'remove-column glyphicon glyphicon-remove', onClick: @remove})

      (li {className: 'column'},
        (h2 {}, @props.title),
        closeButton,
        (div {className: 'column-content'},
          (ul {className: 'cards'},
            @paperProfiles()
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


  PaperProfile: React.createClass
    displayName: "PaperProfile"
    render: ->
      {div, h4, a} = React.DOM

      (div {className: 'paper-profile'}, [
        (a {href: @props.profile.paper_path, className: 'paper-title'},
          (h4 {}, @props.profile.title)),

        for task in @props.profile.tasks
          (Tahi.flowManager.Card {task: task, flowCard: true})])
