ETahi.initializer
  name: 'errorHandler'
  after: 'currentUser'

  initialize: (container, application) ->
    errorPath = '/errors'

    logError = (msg) ->
      if window.teaspoonTesting == true
        console.log("ERROR: " + msg)
      else
        ETahi.RESTless.post errorPath,
          message: msg

    container.register('logError:main', logError , instantiate: false)
    application.inject('route', 'logError', 'logError:main')

    displayErrorMessage = (message) ->
      applicationController = container.lookup('controller:application')
      # these checks are purely for javascript testing
      if !applicationController.isDestroying && !applicationController.isDestroyed
        Ember.run ->
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
      return if status == 0 && ETahi.environment == "test"
      msg = "Error with #{type} request to #{url}. Server returned #{status}: #{statusText}.  #{thrownError}"
      logError(msg)
      if jqXHR.status == 401
        document.location.href = '/users/sign_in'

      displayErrorMessage("There was a problem with the server.  Your data may be out of sync.  Please reload.")
