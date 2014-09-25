ETahi.InlineEditH1Component = Em.Component.extend
  editing: false
  snapshot: null

  createSnapshot: (->
    @set('snapshot', Em.copy(@get('title')))
  ).observes('editing')

  hasContent: Em.computed.notEmpty('title')

  focusOnEdit: (->
    if @get('editing')
      Em.run.schedule 'afterRender', @, ->
        @$('input[type=text]').focus()
  ).observes('editing')

  actions:
    toggleEdit: ->
      @sendAction('setTitle', @get('snapshot')) if @get('editing')
      @toggleProperty 'editing'

    save: ->
      if @get('hasContent')
        @sendAction('setTitle', @get('title'))
        @toggleProperty 'editing'
