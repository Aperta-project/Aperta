###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.assignEditor =
  init: ->
    Tahi.overlay.init 'assign-editor', @createComponent

  createComponent: (target, props) ->
    props.editorId = target.data('editorId')
    props.editors = target.data('editors')
    Tahi.overlays.assignEditor.components.AssignEditorOverlay props

  components:
    AssignEditorOverlay: React.createClass
      render: ->
        {main, h1, select, option, input, label} = React.DOM
        editors = [[null, 'Please select editor']].concat @props.editors

        (Tahi.overlays.components.Overlay {
            onOverlayClosed: @props.onOverlayClosed
            paperTitle: @props.paperTitle
            paperPath: @props.paperPath
            closeCallback: Tahi.overlays.figures.hideOverlay
            taskPath: @props.taskPath
            taskCompleted: @props.taskCompleted
            onOverlayClosed: @props.onOverlayClosed
            onCompletedChanged: @props.onCompletedChanged
            assigneeId: @props.assigneeId
            assignees: @props.assignees
          },
          (main {}, [
            (h1 {}, 'Assign Editor'),
            (Tahi.overlays.components.RailsForm {action: @props.taskPath}, [
              (input {type: 'hidden', name: "task[paper_roles][]", value: null}),
              (label {htmlFor: 'task_paper_role_attributes_user_id'}, 'Editor'),
              (select {id: 'task_paper_role_attributes_user_id', name: 'task[paper_role_attributes][user_id]', className: 'chosen-select', defaultValue: @props.editorId},
                editors.map (editor) -> (option {value: editor[0]}, editor[1])
              )
            ])
          ])
        )

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('select', form)
