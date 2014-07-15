ETahi.ApplicationController = Ember.Controller.extend
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
