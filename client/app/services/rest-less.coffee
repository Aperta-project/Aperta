`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

RESTless = Ember.Namespace.create
  pathFor: (model) ->
    adapter = model.get('store').adapterFor(model)
    resourceType = model.constructor.modelName
    adapter.buildURL(resourceType, model.get('id'))

  ajaxPromise: (method, path, data) ->
    socketId = window.Tahi.__container__.lookup('pusher:main').get('socketId')
    new Ember.RSVP.Promise (resolve, reject) ->
      Ember.$.ajax
        url: path
        type: method
        data: data
        success: resolve
        error: reject
        headers:
          'PUSHER_SOCKET_ID': socketId
        dataType: 'json'

  delete: (path, data) ->
    @ajaxPromise('DELETE', path, data)

  put: (path, data) ->
    @ajaxPromise('PUT', path, data)

  post: (path, data) ->
    @ajaxPromise('POST', path, data)

  get: (path, data) ->
    @ajaxPromise('GET', path, data)

  putModel: (model, path, data) ->
    @put("#{@pathFor(model)}#{path}", data)

  putUpdate: (model, path, data) ->
    @putModel(model, path, data).then (response) ->
      model.get('store').pushPayload(response)
    , (xhr) ->
      if errors = xhr.responseJSON.errors
        errors = Utils.camelizeKeys(errors)
        modelErrors = model.get('errors')
        Object.keys(errors).forEach (key) ->
          modelErrors.add(key, errors[key])
      throw {status: xhr.status, model: model}

  authorize: (controller, url, property) ->
    authorize = (value) ->
      (result) ->
        Ember.run ->
          controller.set(property, value)
    Ember.$.ajax url,
      success: authorize(true)
      error:authorize(false)

`export default RESTless`
