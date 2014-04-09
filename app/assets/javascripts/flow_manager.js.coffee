FlowManagerHeader = React.createClass
  displayName: "FlowManagerHeader"

  displayChangeOverlay: (e) ->
    e.preventDefault()
    React.renderComponent ChooseFlowManagerColumn(), document.getElementById('overlay')
    $('#overlay').show()

  render: ->
    {ul, div, section, img, h2, span, li, a, section} = React.DOM

    (div {id:'control-bar-container'},
      div {id:'control-bar'},
        section {},
          ul {},
            li {},
              a {className: 'add-column-button secondary-button', href: "#", onClick: @displayChangeOverlay},
              "Add New Column",
              " ",
              span {className: 'glyphicon glyphicon-plus'})

ChooseFlowManagerColumn = React.createClass
  displayName: 'chooseFlowManagerColumnOverlay'

  addColumnToFlowManager: (e)->
    e.preventDefault()
    newFlowName = $(e.target).data('flowTitle')

    $.ajax
      method: 'POST'
      url: 'user_settings'
      data:
        _method: 'PATCH'
        flow_title: newFlowName
      success: ->
        React.unmountComponentAtNode document.getElementById('flow-manager')
        Tahi.flowManager.init()
        $('#overlay').hide()

  render: ->
    {div, h2, a, li, span, ul} = React.DOM
    (div {className: 'flow-manager-column-overlay'},
      (a {href: "#", className: 'close-button', onClick: Tahi.overlay.hide}, span {className: 'glyphicon glyphicon-remove'}),
      (h2 {className: "modal-heading"}, "Choose a new column"),
      (ul {className: "modal-buttons list-unstyled"},
        li {}, (a {className: 'secondary-button btn-lg', onClick: @addColumnToFlowManager, 'data-flow-title': "Up for grabs"}, "Up for grabs"),
        li {}, (a {className: 'secondary-button btn-lg', onClick: @addColumnToFlowManager, 'data-flow-title': "My Tasks"}, "My Tasks"),
        li {}, (a {className: 'secondary-button btn-lg', onClick: @addColumnToFlowManager, 'data-flow-title': "My Papers"}, "My Papers"),
        li {}, (a {className: 'secondary-button btn-lg', onClick: @addColumnToFlowManager, 'data-flow-title': "Done"}, "Done")))

Tahi.flowManager =
  init: ->
    if columns = document.getElementById('flow-manager')
      columns = Tahi.flowManager.Columns flows: [], route: columns.getAttribute("data-url")
      React.renderComponent columns, document.getElementById('flow-manager')

  Columns: React.createClass
    displayName: "Columns"
    componentWillMount: ->
      @setState @props

    componentDidMount: ->
      Tahi.utils.bindColumnResize()
      @getFlows()

    getFlows: ->
      $.getJSON @props.route, (data, status) =>
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
      (div {className: 'full-height'},
        (div {}, FlowManagerHeader {}),
        (ul {className: 'columns'},
          for flow, index in @state.flows
            Tahi.flowManager.Column
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
        )
      )

  Column: React.createClass
    displayName: "Column"

    getInitialState: ->
      hovered: false

    paperProfiles: ->
      {li} = React.DOM
      for paperProfile in @props.paperProfiles
        (li {}, Tahi.flowManager.PaperProfile {profile: paperProfile})

    remove: ->
      @props.onRemove @props.index

    componentDidMount: ->

    toggleHover: ->
      @setState
        hovered: !@state.hovered

    render: ->
      {h2, div, ul, li} = React.DOM

      closeButton = ' '
      closeButton = (div {className: "#{if @state.hovered then '' else 'hidden'} remove-column glyphicon glyphicon-remove", onClick: @remove})

      (li {className: 'column', onMouseEnter: @toggleHover, onMouseLeave: @toggleHover },
        (div {className: "column-header"},
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
