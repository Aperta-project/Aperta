`import Flash from 'tahi/services/flash'`

FlashMessages =
  name: 'flashMessages'

  initialize: (container, application) ->
    container.register 'flashMessages:main', Flash
    application.inject 'route',      'flash', 'flashMessages:main'
    application.inject 'controller', 'flash', 'flashMessages:main'
    application.inject 'component:flashMessages', 'flash', 'flashMessages:main'

    Ember.Route.reopen
      enter: ->
        @_super.apply this, arguments

        routeName = @get 'routeName'
        target    = @get 'router.router.activeTransition.targetName'

        if routeName != 'loading' && routeName == target
          @flash.clearMessages()

`export default FlashMessages`
