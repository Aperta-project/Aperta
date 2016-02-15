import { module, test } from 'qunit';
import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const FakeObject = Ember.Object.extend(ValidationErrorsMixin);

module('ValidationErrorsMixin', {
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

test('#displayValidationErrorsFromResponse', function(assert) {
  this.object.displayValidationErrorsFromResponse({
    errors: {
      'email': ['is required', 'invalid format'],
    }
  });

  const errors = this.object.get('validationErrors')['email'];

  assert.equal(errors, 'is required, invalid format', 'errors found');
});

test('#displayValidationErrorsFromResponse with options', function(assert) {
  this.object.displayValidationErrorsFromResponse({
    errors: {
      'email': ['is required', 'invalid format'],
    }
  }, {
    includeNames: true
  });

  const errors = this.object.get('validationErrors')['email'];

  assert.equal(errors, 'Email is required,invalid format', 'errors found');
});
