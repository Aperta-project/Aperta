import Ember from 'ember';
import Utils from 'tahi/services/utils';

export default Ember.Mixin.create({
  prepareResponseErrors: function(errors) {
    return Utils.deepJoinArrays(Utils.deepCamelizeKeys(errors));
  },

  typeFromModel: function(model) {
    return model.get('constructor.typeKey').pluralize();
  },

  createModelProxyObjectWithErrors: function(models) {
    var self = this;
    return models.map(function(model) {
      return Ember.Object.create({
        model: model,
        errors: self.validationErrorsForModel(model)
      });
    });
  },

  validationErrors: null,

  validationErrorsForType: function(model) {
    return this.get('validationErrors')[this.typeFromModel(model)] || {};
  },

  validationErrorsForModel: function(model) {
    return this.validationErrorsForType(model)[model.get('id')];
  },

  displayValidationError: function(key, value) {
    this.set('validationErrors.' + key, (Ember.isArray(value) ? value.join(', ') : value));
  },

  displayValidationErrorsFromResponse: function(response) {
    this.set('validationErrors', this.prepareResponseErrors(response.errors));
  },

  clearValidationErrors: function() {
    this.set('validationErrors', {});
  },

  clearValidationErrorsForModel: function(model) {
    delete this.validationErrorsForType(model)[model.get('id')];
  }
});
