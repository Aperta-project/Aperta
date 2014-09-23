ETahi.initializer
  name: 'errorHandler'
  after: 'currentUser'

  initialize: (container, application) ->
    errorPath = '/errors'

    logError = (msg) ->
      if window.teaspoonTesting == true
        console.log("ERROR: " + msg)
      else
        Em.$.ajax errorPath,
          type: 'POST'
          data:
            message: msg

    displayErrorMessage = (message) ->
      applicationController = container.lookup('controller:application')
      # these checks are purely for javascript testing
      if !applicationController.isDestroying && !applicationController.isDestroyed
        applicationController.set('error', message)

    # The global error handler
    Ember.onerror = (error) ->
      logError("\n" + error.message + "\n" + error.stack + "\n")
      if ETahi.environment == 'development'
        throw error
      else
        displayErrorMessage(error)

    $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
      {type, url} = ajaxSettings
      {status, statusText} = jqXHR

      # don't blow up in case of a 403 from rails when doing authorization checks.
      return if jqXHR.getResponseHeader('Tahi-Authorization-Check') == 'true'
      return if status == 422 # ember data should handle these errors.

      #don't blow up if blowing up blows up
      return if url == errorPath
      msg = "Error with #{type} request to #{url}. Server returned #{status}: #{statusText}"
      logError(msg)
      if jqXHR.status == 401
        document.location.href = '/users/sign_in'

      displayErrorMessage("There was a problem with the server.  Your data may be out of sync.  Please reload.")
