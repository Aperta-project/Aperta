camelizeKeys = (object) ->
  camelized = {}
  Ember.keys(object).forEach (key) ->
    camelized[Ember.String.camelize(key)] = object[key]
  camelized

ETahi.RESTless = Ember.Namespace.create
  ajaxPromise: (method, path) ->
    new Ember.RSVP.Promise (resolve, reject) ->
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
    , (xhr) ->
        if errors = xhr.responseJSON.errors
          errors = camelizeKeys(errors)
          modelErrors = model.get('errors')
          Ember.keys(errors).forEach (key) ->
            modelErrors.add(key, errors[key])
        throw {status: xhr.status, model: model}
