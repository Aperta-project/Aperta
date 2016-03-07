import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const {
  assert,
  isEmpty,
  Object
} = Ember;

const ObjectProxy = Object.extend(ValidationErrorsMixin, {
  errorsPresent: false,
  validations: null,
  questionValidations: null,

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

  validateAll() {
    this.set('validationErrors.save', '');

    _.keys(this.get('validations')).forEach((key) => {
      this.validateProperty(key);
    });

    _.keys(this.get('questionValidations')).forEach((key) => {
      this.validateQuestion(key);
    });

    const errorsPresent = this.validationErrorsPresent();

    this.set('errorsPresent', errorsPresent);

    if(errorsPresent) {
      this.set('validationErrors.save', 'Please fix the errors above');
    }
  },

  validateProperty(key) {
    this.validate(key, this.get(`object.${key}`));

    if(this.validationErrorsPresentForKey(key)) {
      this.set('errorsPresent', true);
    }
  },

  validateQuestion(ident) {
    const value = this.get('object').findQuestion(ident);
    this.validate(ident, value);

    if(this.validationErrorsPresentForKey(ident)) {
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
