ETahi.InlineEditCheckboxComponent = Em.Component.extend
  editing: false
  isNew: false
  checked: true

  hasNoContent: (->
    Em.isEmpty(@get('bodyPart.value'))
  ).property('bodyPart.value')

  focusOnEdit: (->
    if @get('editing')
      Em.run.schedule 'afterRender', @, ->
        @$('textarea').focus()
  ).observes('editing')

  checked: (->
    !Em.isEmpty(@get('bodyPart.answer'))
  ).observes('bodyPart.answer')

  actions:
    toggleEdit: ->
      if @get('isNew')
        @set('bodyPart', null)
      else
        @get('model').rollback()
      @toggleProperty 'editing'

    save: ->
      unless @get('hasNoContent')
        if @get('isNew')
          @get('model.body').pushObject(@get('bodyPart'))
          @set('bodyPart', null)
        @get('model').save()
        @toggleProperty 'editing'
