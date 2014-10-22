ETahi.ValidatesAssociatedModels = Ember.Mixin.create
  validationErrors: {}

  setValidationErrors: (errors) ->
    @set('validationErrors', Tahi.utils.camelizeKeys(errors))

  clearValidationErrors: ->
    @set('validationErrors', {})

  associatedErrors: (model) ->
    @validationErrorsForType(model)[model.get('id')]

  clearModelErrors: (model) ->
    delete @validationErrorsForType(model)[model.get('id')]

  validationErrorsForType: (model) ->
    errorKey = model.get('constructor.typeKey').pluralize()
    @get('validationErrors')[errorKey] || {}

  modelsWithValidationErrors: (models) ->
    models.map (model) =>
      Ember.Object.create
        model: model
        errors: @associatedErrors(model)
