import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const { assert, isEmpty } = Ember;

const ObjectProxy = Ember.Object.extend(ValidationErrorsMixin, {
  errorsPresent: false,
  validations: null,

  init() {
    this._super(...arguments);

    const klass = 'ObjectProxyWithValidationErrors';
    const validationsEmpty = isEmpty(this.get('validations'));
    const questionValidationsEmpty = isEmpty(this.get('questionValidations'));

    assert(
      `the 'object' property must be set for #{klass}`,
      !isEmpty(this.get('object'))
    );

    assert(
      `the 'validations' or 'questionValidations' property must be set for ${klass}`,
      !validationsEmpty || !questionValidationsEmpty
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
