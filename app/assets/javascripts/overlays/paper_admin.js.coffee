window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.paperAdmin =
  Overlay: React.createClass
    componentWillMount: ->
      @setState @props

    componentWillReceiveProps: (nextProps) ->
      @setState nextProps

    render: ->
      {main, h1, select, option, input, label} = React.DOM
      RailsForm = Tahi.overlays.components.RailsForm

      (main {}, [
        (h1 {}, 'Assign Admin'),
        (RailsForm {action: @props.taskPath, ref: 'form'}, [
          (label {htmlFor: 'task_assignee_id'}, 'Assign admin to:'),
          (Chosen {
             id: 'task_assignee_id',
             name: 'task[assignee_id]',
             value: @state.adminId,
             onChange: @handleChange,
             width: '200px'},
            @admins().map (admin) ->
              (option {value: admin[0]}, admin[1]))])])

    handleChange: (e) ->
      @setState adminId: e.target.value
      @refs.form.submit()

    admins: ->
      return [] unless @props.admins
      [[null, 'Please select admin']].concat @props.admins
