ETahi.ApplicationController= Ember.Controller.extend
  currentUser: ->
    userId = Tahi.currentUser.id.toString()
    @store.getById('user', userId)
