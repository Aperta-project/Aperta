ETahi.RolesShowView = Ember.View.extend
  classNameBindings: [':admin-role', 'isEditing:is-editing:not-editing']

  isNew: Em.computed.alias('controller.content.isNew')
  isEditing: Em.computed.alias('controller.isEditing')

  _animateInIfNewRole: (->
    @$().hide().fadeIn(250) if @get('isNew')
  ).on('didInsertElement')

  focusObserver: (->
    if @get('controller.isEditing')
      Ember.run.schedule 'afterRender', =>
        @$('input:first').focus()
  ).observes('controller.isEditing')

  click: (e) ->
    unless @get 'isEditing'
      @set 'isEditing', true
      e.stopPropagation()

  actions:
    delete: ->
      @$().fadeOut 250, =>
        @get('controller').send('delete')

    cancel: ->
      sendCancel = => @get('controller').send('cancel')

      if @get('isNew')
        @$().fadeOut 250, ->
          sendCancel()
      else
        sendCancel()
