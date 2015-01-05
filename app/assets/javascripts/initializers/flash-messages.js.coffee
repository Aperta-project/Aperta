flash = Ember.Object.extend
  messages: []

  displayMessage: (type, message) ->
    @get('messages').pushObject
      text: message
      type: type

  displayErrorMessagesFromResponse: (response) ->
    errors = (for own key, value of response.errors
      "#{key.underscore().replace('_', ' ').capitalize()} #{value}"
    )
    errors.forEach (message) =>
      @displayMessage 'error', message

  clearMessages: ->
    @set 'messages', []

ETahi.initializer
  name: 'flashMessages'

  initialize: (container, application) ->
    container.register 'flashMessages:main', flash
    application.inject 'route',      'flash', 'flashMessages:main'
    application.inject 'controller', 'flash', 'flashMessages:main'

    Ember.Route.reopen
      enter: ->
        @_super.apply this, arguments

        routeName = @get 'routeName'
        target    = @get 'router.router.activeTransition.targetName'

        if routeName != 'loading' && routeName == target
          @flash.clearMessages()
