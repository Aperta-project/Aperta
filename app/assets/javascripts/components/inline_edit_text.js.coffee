ETahi.InlineEditTextComponent = Em.Component.extend
  editing: false
  isNew: false

  hasNoContent: (->
    Em.isEmpty(@get('bodyPart.value'))
  ).property('bodyPart.value')

  focusOnEdit: (->
    if @get('editing')
      Em.run.schedule 'afterRender', @, ->
        @$('textarea').focus()
  ).observes('editing')

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
