`import Ember from 'ember'`

TogglePaperEditableComponent = Ember.Component.extend
  classNames: ['edit-paper-button button-primary']
  classNameBindings: ['buttonColor']

  click: ->
    @sendAction() if @get('buttonState') != 'disabled'

  buttonState: (->
    if !@get('canEdit')
      'disabled'
    else
      if @get('isEditing')
        'isEditing'
      else
        'canEdit'
  ).property('canEdit', 'isEditing')

  buttonStates:
    isEditing:
      buttonColor: 'button--purple'
      prompt: 'stop writing'
      iconClass: ''
    canEdit:
      buttonColor: 'button--green'
      prompt: 'start writing'
      iconClass: 'glyphicon-pencil'
    disabled:
      buttonColor: 'button--disabled'
      prompt: 'start writing'
      iconClass: 'glyphicon-pencil'

  buttonColor: (->
    state = @get('buttonState')
    @get('buttonStates')[state].buttonColor
  ).property('buttonState')

  prompt: (->
    state = @get('buttonState')
    @get('buttonStates')[state].prompt
  ).property('buttonState')

  iconClass: (->
    state = @get('buttonState')
    @get('buttonStates')[state].iconClass
  ).property('buttonState')

`export default TogglePaperEditableComponent`
