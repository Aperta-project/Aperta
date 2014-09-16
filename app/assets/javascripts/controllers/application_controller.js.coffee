ETahi.ApplicationController = Ember.Controller.extend
  delayedSave: false
  currentUser: ( ->
    @getCurrentUser()
  ).property()

  isLoggedIn: ( ->
    !Ember.isBlank(@get('currentUser.id'))
  ).property('currentUser.id')

  isAdmin: Ember.computed.alias 'currentUser.admin'
  username: Ember.computed.alias 'currentUser.username'
  canViewAdminLinks: false

  # this will get overridden by inject except in testing cases.
  getCurrentUser: -> null

  clearError:( ->
    @set('error', null)
  ).observes('currentPath')

  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: []

  defaultBackground: 'overlay_background'

  testing: ( ->
    Ember.testing || ETahi.environment == "test"
  ).property()

  showSaveStatusDiv: Ember.computed.and('testing', 'delayedSave')
