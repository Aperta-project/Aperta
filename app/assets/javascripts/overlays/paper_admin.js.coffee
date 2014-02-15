window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.paperAdmin =
  Overlay: React.createClass
    componentWillReceiveProps: (nextProps) ->
      @setState nextProps
    
    render: ->
      {main, h1, select, option, input, label} = React.DOM
      RailsForm = Tahi.overlays.components.RailsForm

      window.selects ||= []

      mySelect = (select {
             id: 'task_assignee_id',
             name: 'task[assignee_id]',
             className: 'chosen-select',
             defaultValue: @props.adminId,
             ref: 'adminSelect'},
            @admins().map (admin) -> (option {value: admin[0]}, admin[1]))

      window.selects.push mySelect

      console.log "===> props admin Id", @props.adminId
      console.log "===> state admin Id", @state?.adminId

      console.log "===> rendering select"
      (main {}, [
        (h1 {}, 'Assign Admin'),
        (RailsForm {action: @props.taskPath}, [
          (label {htmlFor: 'task_assignee_id'}, 'Assign admin to:'),
          mySelect
          ])])

    admins: ->
      return [] unless @props.admins
      [[null, 'Please select admin']].concat @props.admins

    submitFormsOnChange: (rootNode) ->
      form = $('form', rootNode)
      Tahi.setupSubmitOnChange form, $('select', form)

    componentDidUpdate: (previousProps, previousState, rootNode) ->
      domNode = @refs.adminSelect.getDOMNode()
      console.log "===> updating chosen"
      $(domNode).trigger('chosen:updated')
      @submitFormsOnChange(rootNode)
