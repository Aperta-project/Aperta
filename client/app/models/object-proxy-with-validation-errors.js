import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const ObjectProxy = Ember.Object.extend(ValidationErrorsMixin, {
  errorsPresent: false,
  validations: null,

  init() {
    this._super(...arguments);

    const klass = 'ObjectProxyWithValidationErrors';

    Ember.assert(
      `the 'object' property must be set for #{klass}`,
      !Ember.isEmpty(this.get('object'))
    );

    Ember.assert(
      `the 'validations' property must be set for ${klass}`,
      !Ember.isEmpty(this.get('validations'))
    );
  },

  validateAllKeys() {
    this.set('validationErrors.save', '');

    _.keys(this.get('validations')).forEach((key) => {
      this.validateKey(key);
    });

    const errorsPresent = this.validationErrorsPresent();

    this.set('errorsPresent', errorsPresent);

    if(errorsPresent) {
      this.set('validationErrors.save', 'Please fix the errors above');
    }
  },

  validateKey(key) {
    this.validate(key, this.get(`object.${key}`));

    if(this.validationErrorsPresentForKey(key)) {
      this.set('errorsPresent', true);
    }
  }
});

ObjectProxy.reopenClass({
  errorsPresentInCollection(collection) {
    return !!(
      _.compact(collection.map(function(obj) {
        return obj.get('errorsPresent');
      }))
    ).length;
  }
});

export default ObjectProxy;
