window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.paperAdmin =
  init: ->
    Tahi.overlay.init 'paper-admin', @createComponent

  createComponent: (target, props) ->
    props.adminId = target.data('adminId')
    props.admins = target.data('admins')
    Tahi.overlays.paperAdmin.components.PaperAdminOverlay props

  components:
    PaperAdminOverlay: React.createClass
      render: ->
        {main, h1, select, option, input, label} = React.DOM
        admins = [['', 'Please select admin']].concat @props.admins

        (Tahi.overlays.components.Overlay {
            onOverlayClosed: @props.onOverlayClosed
            paperTitle: @props.paperTitle
            paperPath: @props.paperPath
            closeCallback: Tahi.overlays.figures.hideOverlay
            taskPath: @props.taskPath
            taskCompleted: @props.taskCompleted
            onOverlayClosed: @props.onOverlayClosed
            onCompletedChanged: @props.onCompletedChanged
          },
          (main {}, [
            (h1 {}, 'Assign Admin'),
            (Tahi.overlays.components.RailsForm {action: @props.taskPath}, [
              (label {htmlFor: 'task_assignee_id'}, 'Assign admin to:'),
              (select {id: 'task_assignee_id', name: 'task[assignee_id]', className: 'chosen-select', defaultValue: @props.adminId},
                admins.map (admin) -> (option {value: admin[0]}, admin[1])
              )
            ])
          ])
        )

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('select', form)
