`import ENV from 'tahi/config/environment'`

ErrorHandler =
  name: 'errorHandler'
  after: 'flashMessages'

  initialize: (container, application) ->
    flash     = container.lookup('flashMessages:main')
    logError  = (msg) ->
      e = new Error(msg)
      console.log(e.message) if e.message
      console.log(e.stack || e.message)

    container.register('logError:main', logError , instantiate: false)
    application.inject('route', 'logError', 'logError:main')

    # do not handle errors in dev
    if ENV.environment != 'development'
      # The global error handler for internal ember errors
      Ember.onerror = (error) ->
        if ENV.environment == 'production'
          if Bugsnag && Bugsnag.notifyException
            Bugsnag.notifyException(error, "Uncaught Ember Error")
        else
          flash.displayMessage 'error', error
          logError('\n' + error.message + '\n' + error.stack + '\n')

    # Server response error handler
    $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
      {type, url} = ajaxSettings
      {status, statusText} = jqXHR

      # don't blow up in case of a 403 from rails
      return if status == 403
      # ember data should handle these errors.
      return if status == 422
      # session invalid, redirect to sign in
      return document.location.href = '/users/sign_in' if status == 401

      msg = "Error with #{type} request to #{url}. Server returned #{status}: #{statusText}.  #{thrownError}"
      logError(msg)
      # TODO: Remove this condidition when we switch to run loop respecting http mocks
      flash.displayMessage('error', msg) unless Ember.testing

`export default ErrorHandler`
