ETahi.ApplicationController= Ember.Controller.extend
  currentUser:(->
    userId = Tahi.currentUser?.id.toString()
    @store.getById('user', userId)
  ).property().volatile()

  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: null

  defaultBackground: 'overlay_background'
