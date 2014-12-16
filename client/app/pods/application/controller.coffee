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

`export default ApplicationController`
