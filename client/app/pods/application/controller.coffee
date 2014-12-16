`import Ember from 'ember'`

ApplicationController = Ember.Controller.extend
  delayedSave: false

  isLoggedIn: ( ->
    !Ember.isBlank(@currentUser)
  ).property('currentUser')

  isAdmin: Ember.computed.alias 'currentUser.siteAdmin'
  canViewAdminLinks: false
  canViewFlowManagerLink: false

  clearError:( ->
    @set('error', null)
  ).observes('currentPath')

  resetScrollPosition:( ->
    window.scrollTo(0,0)
  ).observes('currentPath')

  overlayBackground: Ember.computed.oneWay('defaultBackground')

  overlayRedirect: []

  defaultBackground: 'overlay_background'

  testing: ( ->
    Ember.testing || ETahi.environment == 'test'
  ).property()

  showSaveStatusDiv: Ember.computed.and('testing', 'delayedSave')

  navigationVisible: false

  toggleNavigation: (->
    if @get('navigationVisible')
      $('html').addClass 'navigation-visible'
    else
      $('html').removeClass 'navigation-visible'
  ).observes('navigationVisible')

  actions:
    showNavigation: ->
      @set 'navigationVisible', true

    hideNavigation: ->
      @set 'navigationVisible', false

`export default ApplicationController`
