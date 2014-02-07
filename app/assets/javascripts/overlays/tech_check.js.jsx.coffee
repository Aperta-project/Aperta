###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.techCheck =
  init: ->
    Tahi.overlay.init 'tech-check'

  createComponent: (target, props) ->
    Tahi.overlays.techCheck.components.TechCheckOverlay props

  components:
    TechCheckOverlay: React.createClass
      render: ->
        {main, h1, h3, ul, li, label, select, option} = React.DOM

        (Tahi.overlays.components.Overlay {
            onOverlayClosed: @props.onOverlayClosed
            paperTitle: @props.paperTitle
            paperPath: @props.paperPath
            closeCallback: Tahi.overlays.figure.hideOverlay
            taskPath: @props.taskPath
            taskCompleted: @props.taskCompleted
            onOverlayClosed: @props.onOverlayClosed
            onCompletedChanged: @props.onCompletedChanged
            assigneeId: @props.assigneeId
            assignees: @props.assignees
          },
          (main {}, [
            (h1 {}, "Tech Check"),
            (h3 {}, "Tech check steps"),
            (ul {style: {'list-style-type': 'decimal'}}, [
              (li {}, 'Review ethics statement'),
              (li {}, 'Review competing interest statement'),
              (li {}, 'Review funding disclosure')
            ])
          ])
        )
