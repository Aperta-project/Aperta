ETahi.initializer
  name: 'errorHandler'
  after: 'flashMessages'

  initialize: (container, application) ->
    errorPath = '/errors'
    flash     = container.lookup('flashMessages:main')
    logError  = (msg) ->
      e = new Error(msg)
      console.log(e.stack || e.message)

    container.register('logError:main', logError , instantiate: false)
    application.inject('route', 'logError', 'logError:main')

    # The global error handler
    Ember.onerror = (error) ->
      # TODO Check how it looks when the error happens in the app.
      # YES can delete b/c it is not needed in qunit tests.
      # logError("\n" + error.message + "\n" + error.stack + "\n")

      if ETahi.environment == 'development' || ETahi.environment == 'test'
        throw error
      else
        flash.displayMessage 'error', error
        # TODO run the server in staging mode and see if this works correctly.
        if Bugsnag && Bugsnag.notifyException
          Bugsnag.notifyException(error, "Uncaught Ember Error")

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

      flash.displayMessage 'error', "There was a problem with the server. Your data may be out of sync. Please reload."
