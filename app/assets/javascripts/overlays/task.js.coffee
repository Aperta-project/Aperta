window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.task =
  Overlay: React.createClass
    render: ->
      {main, p, h1} = React.DOM

      (main {}, [
        (h1 {}, @props.taskTitle),
        (p {id: 'task-body'}, @props.taskBody)])
