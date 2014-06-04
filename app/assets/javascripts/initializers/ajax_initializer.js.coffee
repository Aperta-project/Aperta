ETahi.initializer
  name: 'ajaxInitializer'


  initialize: (container, application) ->
    $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
      return if jqXHR.getResponseHeader('TAHI_AUTHORIZATION_CHECK') == 'true'

      applicationController = container.lookup('controller:application')
      applicationController.set('error', 'There was a problem.  Your data may be out of sync.  Please reload.')
