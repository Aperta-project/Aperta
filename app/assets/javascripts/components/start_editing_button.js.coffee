ETahi.StartEditingButtonComponent = Ember.Component.extend
  classNames: ['start-editing-button button-primary']
  classNameBindings: ['buttonColor']
  buttonStates: null

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
      prompt: 'STOP WRITING'
      iconClass: ''
    canEdit:
      buttonColor: 'button--green'
      prompt: 'START WRITING'
      iconClass: 'glyphicon-pencil'
    disabled:
      buttonColor: 'button--disabled'
      prompt: 'START WRITING'
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
