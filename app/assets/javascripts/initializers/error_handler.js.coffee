ETahi.initializer
  name: 'errorHandler'
  after: 'currentUser'

  initialize: (container, application) ->
    displayErrorMessage = (message) ->
      container.lookup('controller:application').set('error', message)

    unless ETahi.environment == "development"
      Ember.onerror = displayErrorMessage

    $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
      # don't blow up in case of a 403 from rails when doing authorization checks.
      return if jqXHR.getResponseHeader('Tahi-Authorization-Check') == 'true'
      return if jqXHR.status == 422 # ember data should handle these errors.
      displayErrorMessage("There was a problem with the server.  Your data may be out of sync.  Please reload.")
