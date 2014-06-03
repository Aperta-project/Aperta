ETahi.RolesShowView = Ember.View.extend
  tagName: 'tbody'

  focusObserver: (->
    if @get('controller.isEditing')
      Ember.run.schedule 'afterRender', =>
        @$('input:first').focus()
  ).observes('controller.isEditing')

  click: (e) ->
    unless @get('controller.isEditing')
      @get('controller').send('edit')
      e.stopPropagation()
