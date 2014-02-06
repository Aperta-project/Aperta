window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.task =
  init: ->
    Tahi.overlay.init 'task', @createComponent

  createComponent: (target, props) ->
    props.taskBody = target.data 'taskBody'
    Tahi.overlays.task.components.TaskOverlay props

  components:
    TaskOverlay: React.createClass
      render: ->
        {main, p, h1} = React.DOM

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
            taskBody: @props.taskBody
          },
          (main {}, [
            (h1 {}, @props.taskTitle),
            (p {id: 'task-body'}, @props.taskBody)
          ]))
