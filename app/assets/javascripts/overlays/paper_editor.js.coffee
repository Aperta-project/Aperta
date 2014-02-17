window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.paperEditor =
  Overlay: React.createClass
    render: ->
      {main, h1, select, option, input, label} = React.DOM
      RailsForm = Tahi.overlays.components.RailsForm

      (main {}, [
        (h1 {}, 'Assign Editor'),
        (RailsForm {action: @props.taskPath}, [
          (label {htmlFor: 'task_paper_role_attributes_user_id'}, 'Editor'),
          (Chosen {
             id: 'task_paper_role_attributes_user_id',
             name: 'task[paper_role_attributes][user_id]',
             defaultValue: @props.editorId,
             width: "200px"},
            @editors().map (editor) ->
              (option {value: editor[0]}, editor[1]))])])

    editors: ->
      return [] unless @props.editors
      [[null, 'Please select editor']].concat @props.editors

    submitFormsOnChange: (rootNode) ->
      form = $('form', rootNode)
      Tahi.setupSubmitOnChange form, $('select', form)

    componentDidMount: (rootNode) ->
      @submitFormsOnChange rootNode

    componentDidUpdate: (previousProps, previousState, rootNode) ->
      @submitFormsOnChange rootNode

