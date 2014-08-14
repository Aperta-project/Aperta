ETahi.InlineEditTextComponent = Em.Component.extend
  editing: true

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
      @get('model').save()
      @toggleProperty 'editing'
