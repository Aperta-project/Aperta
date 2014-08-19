ETahi.InlineEditTextComponent = Em.Component.extend
  editing: false
  isNew: false

  hasContent: (->
    !Em.isEmpty(@get('bodyPart.value'))
  ).property('bodyPart.value')

  hasNoContent: (->
    !@get('hasContent')
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
      if @get('hasContent')
        if @get('isNew')
          @get('model.body').pushObject(@get('bodyPart'))
          @set('bodyPart', null)
        @get('model').save()
        @toggleProperty 'editing'
