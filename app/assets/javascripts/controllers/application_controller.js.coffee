ETahi.ApplicationController = Ember.Controller.extend
  delayedSave: false
  currentUser: ( ->
    @getCurrentUser()
  ).property()

  isLoggedIn: ( ->
    !Ember.isBlank(@get('currentUser.id'))
  ).property('currentUser.id')

  isAdmin: Ember.computed.alias 'currentUser.siteAdmin'
  canViewAdminLinks: false

  # this will get overridden by inject except in testing cases.
  getCurrentUser: -> null

  clearError:( ->
    @set('error', null)
  ).observes('currentPath')

  resetScrollPosition:( ->
    window.scrollTo(0,0)
  ).observes('currentPath')

  overlayBackground: Ember.computed.defaultTo('defaultBackground')

  overlayRedirect: []

  defaultBackground: 'overlay_background'

  testing: ( ->
    Ember.testing || ETahi.environment == "test"
  ).property()

  showSaveStatusDiv: Ember.computed.and('testing', 'delayedSave')

  navigationVisible: false
  accountLinksVisible: false

  actions:
    toggleNavigation: ->
      @toggleProperty 'navigationVisible'

      if @get('navigationVisible')
        $('html').addClass 'navigation-visible'
      else
        $('html').removeClass 'navigation-visible'

    routeTo: (routeName) ->
      @send 'toggleNavigation'
      @set 'accountLinksVisible', false
      @transitionToRoute routeName

    toggleAccountLinks: ->
      @toggleProperty 'accountLinksVisible'
      return false
