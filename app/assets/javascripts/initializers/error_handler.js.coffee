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
      # console.log('Ember.onerror', error)
      if ETahi.environment == 'test'
        # if we do not print this, you can not click on the stack trace
        # and jump to the code where the error happened.
        console.log(error.stack)
        # in test, this error is caught by QUnit and displayed in the UI
        throw error

      if ETahi.environment == 'development'
        flash.displayMessage 'error', error
        throw error
      else
        flash.displayMessage 'error', error
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
