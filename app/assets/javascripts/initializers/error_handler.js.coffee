ETahi.initializer
  name: 'errorHandler'
  after: 'currentUser'

  initialize: (container, application) ->
    displayErrorMessage = (message) ->
      container.lookup('controller:application').set('error', message)

    Ember.onerror = displayErrorMessage

    $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
      return if jqXHR.getResponseHeader('TAHI_AUTHORIZATION_CHECK') == 'true'
      displayErrorMessage("There was a problem with the server.  Your data may be out of sync.  Please reload.")
