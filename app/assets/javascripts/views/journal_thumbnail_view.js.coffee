ETahi.JournalThumbnailController = Ember.ObjectController.extend
  needs: ['application']
  currentUser: Ember.computed.alias 'controllers.application.currentUser'
  isEditing: false
  actions:
    editJournalDetails: ->
      @set 'isEditing', true
      debugger


ETahi.JournalThumbnailView = Ember.View.extend
  isHovering: false
  mouseEnter: -> @set('isHovering', true)
  mouseLeave: -> @set('isHovering', false)
