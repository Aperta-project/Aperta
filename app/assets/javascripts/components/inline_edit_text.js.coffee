ETahi.InlineEditTextComponent = Em.Component.extend
  editing: true
  hasNoContent: (->
    Em.isEmpty(@get('text'))
  ).property('text')

  focusOnEdit: (->
    if @get('editing')
      Em.run.schedule 'afterRender', @, ->
        @$('input[type=text]').focus()
  ).observes('editing')

  actions:
    toggleEdit: ->
      @get('model').rollback()
      @toggleProperty 'editing'

    save: ->
      unless @get('hasNoContent')
        @get('model').save()
        @toggleProperty 'editing'
