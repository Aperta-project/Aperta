`import Utils from 'tahi/services/utils'`
`import ENV from 'tahi/config/environment'`

ErrorHandler =
  name: 'errorHandler'
  after: 'flashMessages'

  initialize: (container, application) ->
    # EMBERCLI TODO - what is this for?
    return
    errorPath = '/errors'
    flash     = container.lookup('flashMessages:main')
    logError  = (msg) ->
      e = new Error(msg)
      console.log(e.stack || e.message)

    container.register('logError:main', logError , instantiate: false)
    application.inject('route', 'logError', 'logError:main')

    # The global error handler
    Ember.onerror = (error) ->
      logError("\n" + error.message + "\n" + error.stack + "\n")
      window.ErrorNotifier.notify(error, "Uncaught Ember Error")
      if ENV.environment == 'development'
        throw error
      else
        flash.displayMessage 'error', error

    $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
      {type, url} = ajaxSettings
      {status, statusText} = jqXHR

      # don't blow up in case of a 403 from rails
      return if status == 403
      return if status == 422 # ember data should handle these errors.

      # don't blow up if blowing up blows up
      return if url == errorPath
      return if status == 0 && ENV.environment == 'test'
      msg = "Error with #{type} request to #{url}. Server returned #{status}: #{statusText}.  #{thrownError}"
      logError(msg)
      if jqXHR.status == 401
        document.location.href = '/users/sign_in'

      flash.displayMessage 'error', 'There was a problem with the server. Your data may be out of sync. Please reload.'

`export default ErrorHandler`
