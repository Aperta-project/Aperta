ETahi.initializer
  name: 'errorHandler'
  after: 'currentUser'

  initialize: (container, application) ->
    logError = (error) ->
      Em.$.ajax '/errors',
        type: 'POST'
        data:
          stack: error.stack


    displayErrorMessage = (message) ->
      applicationController = container.lookup('controller:application')
      # these checks are purely for javascript testing
      if !applicationController.isDestroying && !applicationController.isDestroyed
        applicationController.set('error', message)

    Ember.onerror = (error) ->
      logError(error)
      unless ETahi.environment == 'development'
        displayErrorMessage(error)

    $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
      # don't blow up in case of a 403 from rails when doing authorization checks.
      return if jqXHR.getResponseHeader('Tahi-Authorization-Check') == 'true'
      return if jqXHR.status == 422 # ember data should handle these errors.
      logError(thrownError)
      if jqXHR.status == 401
        document.location.href = '/users/sign_in'

      displayErrorMessage("There was a problem with the server.  Your data may be out of sync.  Please reload.")
