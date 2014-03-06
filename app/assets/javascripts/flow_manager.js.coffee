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

    removeFlow: (index) ->
      @state.flows.splice(index, 1)
      @setState {flows: @state.flows}, @saveFlows

    saveFlows: ->
      flowTitles = _.map @state.flows, (flow) -> flow.title
      $.post 'user_settings',
        flows: flowTitles
        _method: 'PATCH'

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
              index: index,
              paperProfiles: flow.paperProfiles,
              title: flow.title
              empty_text: flow.empty_text
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
      @props.onRemove @props.index

    render: ->
      {h2, div, ul, li} = React.DOM

      closeButton = ' '
      closeButton = (div {className: 'remove-column glyphicon glyphicon-remove', onClick: @remove})

      (li {className: 'column'},
        (div {className: "column-title"},
          (h2 {}, @props.title),
          closeButton),
        (div {className: 'column-content'},
          if @props.paperProfiles.length
            (ul {className: 'cards'},
              @paperProfiles())
          else
            (div {className: 'empty-text'}, @props.empty_text)
      ))


  PaperProfile: React.createClass
    displayName: "PaperProfile"
    render: ->
      {div, h4, a} = React.DOM

      (div {className: 'paper-profile'}, [
        (a {href: @props.profile.paper_path, className: 'paper-title'},
          (h4 {}, @props.profile.title)),

        for task in @props.profile.tasks
          (Tahi.columnComponents.Card {task: task, flowCard: true})])
