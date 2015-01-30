ETahi.ValidationErrorsMixin = Em.Mixin.create
  _init: (->
    @clearValidationErrors()
  ).on('init')

  #helpers

  prepareResponseErrors: (errors) ->
    Tahi.utils.deepJoinArrays(Tahi.utils.deepCamelizeKeys(errors))

  createModelProxyObjectWithErrors: (models) ->
    models.map (model) =>
      Ember.Object.create
        model: model
        errors: @validationErrorsForModel(model)


  # getters

  validationErrors: null

  validationErrorsForType: (model) ->
    type = model.get('constructor.typeKey').pluralize()
    @get('validationErrors')[type] || {}

  validationErrorsForModel: (model) ->
    @validationErrorsForType(model)[model.get('id')]


  # setters

  displayValidationError: (key, value) ->
    @set('validationErrors.' + key, (if Ember.isArray(value) then value.join(', ') else value))

  displayValidationErrorsFromResponse: (response) ->
    @set('validationErrors', @prepareResponseErrors(response.errors))

  clearValidationErrors: ->
    @set('validationErrors', {})

  clearValidationErrorsForModel: (model) ->
    delete @validationErrorsForType(model)[model.get('id')]
