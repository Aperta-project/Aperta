ETahi.RolesShowView = Ember.View.extend
  tagName: 'tbody'

  isNew: Em.computed.alias('controller.content.isNew')

  _animateInIfNewRole: (->
    @$().hide().fadeIn(250) if @get('isNew')
  ).on('didInsertElement')

  focusObserver: (->
    if @get('controller.isEditing')
      Ember.run.schedule 'afterRender', =>
        @$('input:first').focus()
  ).observes('controller.isEditing')

  click: (e) ->
    unless @get('controller.isEditing')
      @get('controller').send('edit')
      e.stopPropagation()

  actions:
    cancel: ->
      sendCancel = => @get('controller').send('cancel')

      if @get('isNew')
        @$().fadeOut 250, ->
          sendCancel()
      else
        sendCancel()
