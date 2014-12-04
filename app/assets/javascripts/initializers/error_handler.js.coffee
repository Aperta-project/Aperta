ETahi.initializer
  name: 'errorHandler'
  after: 'currentUser'

  initialize: (container, application) ->
    errorPath = '/errors'

    logError = (msg) ->
      e = new Error(msg)
      console.log(e.stack || e.message)

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
      window.ErrorNotifier.notify(error, "Uncaught Ember Error")
      if ETahi.environment == 'development'
        throw error
      else
        displayErrorMessage(error)

    $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
      {type, url} = ajaxSettings
      {status, statusText} = jqXHR

      # don't blow up in case of a 403 from rails
      return if status == 403
      return if status == 422 # ember data should handle these errors.

      #don't blow up if blowing up blows up
      return if url == errorPath
      return if status == 0 && ETahi.environment == "test"
      msg = "Error with #{type} request to #{url}. Server returned #{status}: #{statusText}.  #{thrownError}"
      logError(msg)
      if jqXHR.status == 401
        document.location.href = '/users/sign_in'

      displayErrorMessage("There was a problem with the server.  Your data may be out of sync.  Please reload.")
