window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.paperAdmin =
  init: ->
    Tahi.overlay.init 'paper-admin'

  createComponent: (target, props) ->
    props.adminId = target.data('adminId')
    props.admins = target.data('admins')
    Tahi.overlays.paperAdmin.components.PaperAdminOverlay props

  components:
    PaperAdminOverlay: React.createClass
      render: ->
        {main, h1, select, option, input, label} = React.DOM
        Overlay = Tahi.overlays.components.Overlay
        RailsForm = Tahi.overlays.components.RailsForm

        admins = [['', 'Please select admin']].concat @props.admins

        (Overlay @props.overlayProps,
          (main {}, [
            (h1 {}, 'Assign Admin'),
            (RailsForm {action: @props.overlayProps.taskPath}, [
              (label {htmlFor: 'task_assignee_id'}, 'Assign admin to:'),
              (select {
                 id: 'task_assignee_id',
                 name: 'task[assignee_id]',
                 className: 'chosen-select',
                 defaultValue: @props.adminId},
                admins.map (admin) -> (option {value: admin[0]}, admin[1]))])]))

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('select', form)
