import { module, test } from 'qunit';
import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const FakeObject = Ember.Object.extend(ValidationErrorsMixin);

module('unit: ValidationErrorsMixin', {
  beforeEach() {
    this.object = FakeObject.create();
  }
});

// #currentValidationErrors -----------------------------------------

test('#currentValidationErrors with error', function(assert) {
  this.object.set('validationErrors', {
    'key':  'error',
    'key2': ''
  });

  const errors = this.object.currentValidationErrors();

  assert.equal(errors.length, 1, 'error found');
});

test('#currentValidationErrors empty', function(assert) {
  this.object.set('validationErrors', {
    'key':  '',
    'key2': ''
  });

  const errors = this.object.currentValidationErrors();

  assert.equal(errors.length, 0, 'no errors found');
});


// #validationErrorsPresent -----------------------------------------

test('#validationErrorsPresent with error', function(assert) {
  this.object.set('validationErrors', {
    'key':  'error',
    'key2': ''
  });

  const errors = this.object.validationErrorsPresent();

  assert.equal(errors, true, 'error found');
});

test('#validationErrorsPresent empty', function(assert) {
  this.object.set('validationErrors', {
    'key':  '',
    'key2': ''
  });

  const errors = this.object.validationErrorsPresent();

  assert.equal(errors, false, 'no errors');
});


// #validationErrorsPresentForKey -----------------------------------

test('#validationErrorsPresentForKey with error', function(assert) {
  this.object.set('validationErrors', {
    'key':  'error',
    'key2': ''
  });

  const errors = this.object.validationErrorsPresentForKey('key');

  assert.equal(errors, true, 'error found');
});

test('#validationErrorsPresentForKey empty', function(assert) {
  this.object.set('validationErrors', {
    'key':  '',
    'key2': ''
  });

  const errors = this.object.validationErrorsPresentForKey('key');

  assert.equal(errors, false, 'no errors');
});


// #displayValidationErrorsFromResponse ------------------------------

// Instead of passing along rails-style errors we now get a JSON API errors
// object that we'll temporarily munge into the old style
// http://emberjs.com/blog/2015/06/18/ember-data-1-13-released.html#toc_new-errors-api
// has more detail, as well as http://jsonapi.org/format/#error-objects
test('#displayValidationErrorsFromResponse', function(assert) {
  let newFormatedErrors = [
    {
      detail: 'must be a whole number',
      source: {
        pointer: '/data/attributes/volume_number'
      }
    },
    {
      detail: 'is required',
      source: {
        pointer: '/data/attributes/email'
      }
    },
    {
      detail: 'invalid format',
      source: {
        pointer: '/data/attributes/email'
      }
    }
  ];

  this.object.displayValidationErrorsFromResponse({ errors: newFormatedErrors });
  let errors = this.object.get('validationErrors.email');
  assert.equal(errors,
               'is required, invalid format',
               'it concatenates multiple error objects details under one key by pointer');
  assert.ok(this.object.get('validationErrors.volumeNumber'),
            'it camelCases the end of the pointer for the error key');

  this.object.displayValidationErrorsFromResponse({ errors: newFormatedErrors},
                                                  {includeNames: true });
  assert.equal(this.object.get('validationErrors.email'),
               'Email is required, invalid format',
               'the includeNames option sticks the source pointer at the beginning');

  this.object.displayValidationErrorsFromResponse({ errors: newFormatedErrors},
                                                  {includeNames: true });
  assert.equal(this.object.get('validationErrors.volumeNumber'),
               'VolumeNumber must be a whole number',
               'includeNames capitalizes the key by default');

  this.object.displayValidationErrorsFromResponse({ errors: newFormatedErrors},
                                                  {includeNames: 'humanize' });
  assert.equal(this.object.get('validationErrors.volumeNumber'),
               'Volume number must be a whole number',
               'includeNames will humanize the key too');

});
