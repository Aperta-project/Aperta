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
        (RailsForm {action: @props.taskPath}, [
          (label {htmlFor: 'task_assignee_id'}, 'Assign admin to:'),
          (select {
             id: 'task_assignee_id',
             name: 'task[assignee_id]',
             className: 'chosen-select',
             value: @state.adminId,
             onChange: @handleChange,
             ref: 'adminSelect'},
            @admins().map (admin) ->
              (option {value: admin[0]}, admin[1]))])])

    handleChange: (e) ->
      debugger
      # $(@refs.adminSelect.getDOMNode()).closest('form').trigger 'submit:rails'
      @setState adminId: e.target.value

    admins: ->
      return [] unless @props.admins
      [[null, 'Please select admin']].concat @props.admins

    submitFormsOnChange: (rootNode) ->
      form = $('form', rootNode)
      Tahi.setupSubmitOnChange form, $('select', form)

    componentDidUpdate: (previousProps, previousState, rootNode) ->
      domNode = @refs.adminSelect.getDOMNode()
      $(domNode).trigger('chosen:updated')
      @submitFormsOnChange(rootNode)
