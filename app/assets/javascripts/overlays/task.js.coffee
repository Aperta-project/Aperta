window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.task =
  init: ->
    Tahi.overlay.init 'task'

  createComponent: (target, props) ->
    props.taskBody = target.data 'taskBody'
    Tahi.overlays.task.components.TaskOverlay props

  components:
    TaskOverlay: React.createClass
      render: ->
        {main, p, h1} = React.DOM

        (Tahi.overlays.components.Overlay @props.overlayProps,
          (main {}, [
            (h1 {}, @props.taskTitle),
            (p {id: 'task-body'}, @props.taskBody)]))
