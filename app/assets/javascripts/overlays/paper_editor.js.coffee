Tahi.overlays.paperEditor =
  Overlay: React.createClass
    componentWillMount: ->
      @setState @props

    componentWillReceiveProps: (nextProps) ->
      @setState nextProps

    render: ->
      {main, h1, select, option, input, label} = React.DOM
      RailsForm = Tahi.overlays.components.RailsForm

      (main {}, [
        (h1 {}, 'Assign Editor'),
        (RailsForm {action: @props.taskPath, ref: 'form' }, [
          (label {htmlFor: 'task_paper_role_attributes_user_id'}, 'Editor'),
          (Chosen {
             id: 'task_paper_role_attributes_user_id',
             name: 'task[paper_role_attributes][user_id]',
             value: @state.editorId,
             onChange: @handleChange,
             width: "200px"},
            @editors().map (editor) ->
              (option {value: editor[0]}, editor[1]))])])

    handleChange: (e) ->
      @setState editorId: e.target.value
      @refs.form.submit()

    editors: ->
      return [] unless @props.editors
      [[null, 'Please select editor']].concat _.map(@props.editors, (e) -> [e.id, e.full_name])
