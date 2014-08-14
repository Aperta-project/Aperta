ETahi.InlineEditH1Component = Em.Component.extend
  editing: false

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
