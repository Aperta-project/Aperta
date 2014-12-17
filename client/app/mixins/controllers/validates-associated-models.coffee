`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

ValidatesAssociatedModels = Ember.Mixin.create
  validationErrors: {}

  setValidationErrors: (errors) ->
    @set('validationErrors', Utils.camelizeKeys(errors))

  clearValidationErrors: ->
    @set('validationErrors', {})

  associatedErrors: (model) ->
    @validationErrorsForType(model)[model.get('id')]

  clearModelErrors: (model) ->
    delete @validationErrorsForType(model)[model.get('id')]

  validationErrorsForType: (model) ->
    errorKey = model.get('constructor.typeKey').pluralize()
    @get('validationErrors')[errorKey] || {}

  decorateWithErrors: (models) ->
    models.map (model) =>
      Ember.Object.create
        model: model
        errors: @associatedErrors(model)

`export default ValidatesAssociatedModels`
