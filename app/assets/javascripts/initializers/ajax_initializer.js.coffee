ETahi.initializer
  name: 'ajaxInitializer'

  initialize: (container, application) ->
    Ember.onerror = (e) ->
      applicationController = container.lookup('controller:application')
      applicationController.set('error', e.message)

    $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) ->
      return if jqXHR.getResponseHeader('TAHI_AUTHORIZATION_CHECK') == 'true'
      throw new Ember.Error('There was a problem with the server.  Your data may be out of sync.  Please reload.')
