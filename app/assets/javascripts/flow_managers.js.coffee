window.Tahi ||= {}

Card = React.createClass
  displayOverlay: (e) ->
    e.preventDefault()

  render: ->
    {p} = React.DOM
    (p {}, @props.title)

PaperProfile = React.createClass
  render: ->
    {div, h1, p} = React.DOM

    (div {}, [
      (h1 {}, @props.profile.title),
      for task in @props.profile.tasks
        (Card task)])

Flow = React.createClass
  render: ->
    {ul, li} = React.DOM

    (ul {},
      for paperProfile in @props.paperProfiles
        (li {}, PaperProfile {profile: paperProfile}))

FlowManager = React.createClass
  render: ->
    {div} = React.DOM
    (div {},
      for flow, index in @props.flows
        Flow {key: "flow-#{index}", paperProfiles: flow.paperProfiles, title: flow.title}
    )

Tahi.flowManager =
  init: ->
    flowManager = FlowManager flows: [window.myTasks]
    React.renderComponent flowManager, document.getElementById('flow-manager')

