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

  post: (path, data) ->
    @ajaxPromise("POST", path, data)

  putModel: (model, path, data) ->
    @put("#{model.path()}#{path}", data)

  putUpdate: (model, path, data) ->
    @putModel(model, path).then (response) ->
      model.get('store').pushPayload(response)
    , (xhr) ->
        if errors = xhr.responseJSON.errors
          errors = Tahi.utils.camelizeKeys(errors)
          modelErrors = model.get('errors')
          Ember.keys(errors).forEach (key) ->
            modelErrors.add(key, errors[key])
        throw {status: xhr.status, model: model}

  authorize: (controller, url, property) ->
    authorize = (value) ->
      (result) ->
        Ember.run ->
          controller.set(property, value)
    Ember.$.ajax url,
      headers:
        'Tahi-Authorization-Check': true
      success: authorize(true)
      error:authorize(false)
