import Ember from 'ember';
import deepJoinArrays from 'tahi/lib/deep-join-arrays';
import deepCamelizeKeys from 'tahi/lib/deep-camelize-keys';
import validator from 'tahi/lib/validator';

const { isArray, isEmpty, on } = Ember;

/**
  ## How to Use

  In your template:

  ```
  {{error-message message=validationErrors.email}}
  <label>
    Email <input>
  </label>
  ```

  In your component:

  ```
  import Ember from 'ember';
  import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

  export default Ember.Component.extend(ValidationErrorsMixin, {
    actions: {
      save() {
        this.get('model').save().then(() => {
          this.clearAllValidationErrors();
        }, (response) => {
          this.displayValidationErrorsFromResponse(response);
        });
      }
    }
  });
  ```

  ## How it Works

  The mixin adds a `validationErrors` property to your Object.
*/

export default Ember.Mixin.create({
  /**
    Create validationErrors property.

    @private
    @method _initValidationErrors
  */

  validationErrors: null,
  _initValidationErrors: on('init', function() {
    if (!this.get('validationErrors')) {
      this.set('validationErrors', {});
    }
  }),

  /**
    Take response from Rails, camelize keys and join arrays.

    @private
    @method _prepareResponseErrors
    @param {Object} errors
    @param {Object} options
    @return {Object}
  */

  _prepareResponseErrors(errors, options) {
    let errorsObject = deepJoinArrays(deepCamelizeKeys(errors));

    if (options && options.includeNames) {
      for(var key in errorsObject) {
        errorsObject[key] = `${key.capitalize()} ${errors[key]}`;
      }
    }
    return errorsObject;
  },

  /**
    Get pluralized name of model.

    @private
    @method _typeFromModel
    @return {String}
  */

  _typeFromModel(model) {
    return model.get('constructor.modelName').camelize().pluralize();
  },

  /**
    TODO: You! Be a good citizen and document this method!

    @method createModelProxyObjectWithErrors
    @param {Array} models Array of (most likely) DS.Models
    @return {Array} array of hashes with `model` and `error` keys
  */

  createModelProxyObjectWithErrors(models) {
    return models.map((model) => {
      return Ember.Object.create({
        model: model,
        errors: this.validationErrorsForModel(model)
      });
    });
  },

  /**
    TODO: You! Be a good citizen and document this method!

    @method validationErrorsForType
    @param {DS.Model}
    @return {Array}
  */

  validationErrorsForType(model) {
    return this.get('validationErrors')[this._typeFromModel(model)] || [];
  },

  /**
    TODO: You! Be a good citizen and document this method!

    @method validationErrorsForModel
    @param {DS.Model}
    @return {Hash}
  */

  validationErrorsForModel(model) {
    return this.validationErrorsForType(model)[model.get('id')];
  },

  /**
    TODO: You! Be a good citizen and document this method!

    @method displayValidationError
    @param {String} key
    @param {String|Array} value
  */

  displayValidationError(key, value) {
    this.set(
      'validationErrors.' + key,
      (isArray(value) ? value.join(', ') : value)
    );
  },

  /**
    Display validation errors.
    Should be called on a unsuccessful save, for example.

    ```
    this.get('model').save().then(() => {
      // success
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
    });
    ```

    Response expected to be in Rails format:

    ```
    { errors: { someProperty: ["is invalid", "another error"] } }
    ```

    @method displayValidationErrorsFromResponse
    @param {Object} response Hash from Ember Data `save` failure.
    @param {Object} options
  */

  displayValidationErrorsFromResponse(response, options) {
    this.set(
      'validationErrors',
      this._prepareResponseErrors(response.errors, options)
    );
  },

  /**
    Remove all validation errors.
    Should be called on a successful save, for example.

    ```
    this.get('model').save().then(() => {
      this.clearAllValidationErrors();
    });
    ```

    @method clearAllValidationErrors
  */

  clearAllValidationErrors() {
    this.set('validationErrors', {});
  },

  /**
    Remove all validation errors for a specific model.

    @method clearAllValidationErrorsForModel
    @param {DS.Model}
  */

  clearAllValidationErrorsForModel(model) {
    delete this.validationErrorsForType(model)[model.get('id')];
  },

  /**
    Validate key

    @method validate
    @param {String} key
    @param {Anything} value
    @param {Array} types names of validations to run
  */

  validate(key, value) {
    const validations = this._getValidationsForKey(key);
    const messages = validator.validate.call(this, key, value, validations);
    this.displayValidationError(key, messages);
  },

  /**
    Find validations in validations or questionValidations object

    @method _getValidationsForKey
    @param {String} key
    @return {Array} validations
    @private
  */

  _getValidationsForKey(key) {
    return this.get('validations')[key];
  },

  /**
    @method validationErrorsPresent
    @return {Boolean}
  */

  validationErrorsPresent() {
    return !isEmpty(this.currentValidationErrors());
  },

  /**
    @method validationErrorsPresentForKey
    @return {Boolean}
  */

  validationErrorsPresentForKey(key) {
    return !isEmpty(this.get('validationErrors')[key]);
  },

  /**
    @method currentValidationErrors
    @return {Array} array of key/value(error message) pairs
  */

  currentValidationErrors() {
    const errors = this.get('validationErrors');

    return _.compact(
      _.map(_.keys(errors), key => {
        if(isEmpty(errors[key]) || Ember.keys(errors[key]).length === 0) {
          return false;
        }

        let hash = {};
        hash[key] = errors[key];
        return hash;
      })
    );
  }
});
