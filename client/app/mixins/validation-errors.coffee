`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

ValidationErrorsMixin = Ember.Mixin.create
  _init: (->
    @clearValidationErrors()
  ).on('init')

  #helpers

  prepareResponseErrors: (errors) ->
    Utils.deepJoinArrays(Utils.deepCamelizeKeys(errors))

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

`export default ValidationErrorsMixin`
