ETahi.RolesRoleView = Ember.View.extend
  tagName: 'tbody'

  focusObserver: (->
    if @get('controller.isEditing')
      Ember.run.schedule 'afterRender', =>
        @$('input:first').focus()
  ).observes('controller.isEditing')
