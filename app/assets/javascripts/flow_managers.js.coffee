window.Tahi ||= {}

Card = React.createClass
  render: ->
    {a} = React.DOM
    (a {
        className: 'card',
        onClick: @displayCard,
        "data-card-name": @props.task.cardName,
        "data-task-path": @props.task.taskPath,
        href: @props.task.taskPath
      },
      @props.task.taskTitle
    )

  displayCard: (event) ->
    Tahi.overlay.display event, @props.task.cardName

PaperProfile = React.createClass
  render: ->
    {div, h4} = React.DOM

    (div {className: 'paper-profile'}, [
      (h4 {}, @props.profile.title),

      for task in @props.profile.tasks
        (Card {task: task})])

Flow = React.createClass
  render: ->
    {h1, ul, li, div} = React.DOM

    (div {className: 'column'},
      (h1 {}, "My Tasks"),
      (ul {},
        for paperProfile in @props.paperProfiles
          (li {}, PaperProfile {profile: paperProfile})))

FlowManager = React.createClass
  render: ->
    {div} = React.DOM
    (div {},
      for flow, index in @props.flows
        Flow {key: "flow-#{index}", paperProfiles: flow.paperProfiles, title: flow.title}
    )

Tahi.flowManager =
  init: ->
    if document.getElementById('flow-manager')
      flowManager = FlowManager flows: [window.myTasks]
      React.renderComponent flowManager, document.getElementById('flow-manager')

