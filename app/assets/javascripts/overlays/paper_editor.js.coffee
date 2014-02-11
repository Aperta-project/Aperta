window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.paperEditor =
  init: ->
    Tahi.overlay.init 'paper-editor'

  createComponent: (target, props) ->
    props.editorId = target.data('editorId')
    props.editors = target.data('editors')
    Tahi.overlays.paperEditor.components.PaperEditorOverlay props

  components:
    PaperEditorOverlay: React.createClass
      render: ->
        {main, h1, select, option, input, label} = React.DOM
        Overlay = Tahi.overlays.components.Overlay
        RailsForm = Tahi.overlays.components.RailsForm

        editors = [[null, 'Please select editor']].concat @props.editors

        (Overlay @props.overlayProps,
          (main {}, [
            (h1 {}, 'Assign Editor'),
            (RailsForm {action: @props.overlayProps.taskPath}, [
              (label {htmlFor: 'task_paper_role_attributes_user_id'}, 'Editor'),
              (select {
                 id: 'task_paper_role_attributes_user_id',
                 name: 'task[paper_role_attributes][user_id]',
                 className: 'chosen-select',
                 defaultValue: @props.editorId},
                editors.map (editor) ->
                  (option {value: editor[0]}, editor[1]))])]))

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('select', form)
