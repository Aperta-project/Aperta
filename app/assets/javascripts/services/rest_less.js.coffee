camelizeKeys = (object) ->
  camelized = {}
  Ember.keys(object).forEach (key) ->
    camelized[Ember.String.camelize(key)] = object[key]
  camelized

ETahi.RESTless = Ember.Namespace.create
  ajaxPromise: (method, path, data) ->
    new Ember.RSVP.Promise (resolve, reject) ->
      Ember.$.ajax
        url: path
        type: method
        data: data
        success: resolve
        error: reject

  put: (path, data) ->
    @ajaxPromise("PUT", path, data)

  putModel: (model, path) ->
    @put("#{model.path()}#{path}", undefined)

  putUpdate: (model, path) ->
    @putModel(model, path).then (data) ->
      model.get('store').pushPayload(data)
    , (xhr) ->
        if errors = xhr.responseJSON.errors
          errors = camelizeKeys(errors)
          modelErrors = model.get('errors')
          Ember.keys(errors).forEach (key) ->
            modelErrors.add(key, errors[key])
        throw {status: xhr.status, model: model}
