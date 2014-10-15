ETahi.RESTless = Ember.Namespace.create
  ajaxPromise: (method, path) ->
    new Ember.RSVP.Promise (resolve, reject) =>
      Ember.$.ajax
        url: path
        type: method
        success: resolve
        error: reject

  put: (model, path) ->
    @ajaxPromise("PUT", "#{model.path()}#{path}")

  putUpdate: (model, path) ->
    @put(model, path).then (data) ->
      model.get('store').pushPayload(data)
