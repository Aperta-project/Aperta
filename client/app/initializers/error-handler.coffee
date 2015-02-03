`import Utils from 'tahi/services/utils'`
`import ENV from 'tahi/config/environment'`

ErrorHandler =
  name: 'errorHandler'
  after: 'flashMessages'

  initialize: (container, application) ->
    flash     = container.lookup('flashMessages:main')
    logError  = (msg) ->
      e = new Error(msg)
      console.log(e.stack || e.message)

    container.register('logError:main', logError , instantiate: false)
    application.inject('route', 'logError', 'logError:main')

    # The global error handler
    Ember.onerror = (error) ->
      logError('\n' + error.message + '\n' + error.stack + '\n')
      window.ErrorNotifier.notify(error, 'Uncaught Ember Error')
      if ENV.environment == 'development'
        flash.displayMessage 'error', error
        throw error

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
      # Buh?
      return if status == 0 && ENV.environment == 'test'

      msg = "Error with #{type} request to #{url}. Server returned #{status}: #{statusText}.  #{thrownError}"
      logError(msg)
      # TODO: Remove this condidition when we switch to run loop respecting http mocks
      displayMessage('error', msg) unless Ember.testing

`export default ErrorHandler`
