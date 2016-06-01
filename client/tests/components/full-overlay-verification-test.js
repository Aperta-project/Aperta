import {
  moduleForComponent,
  test
} from 'ember-qunit';
import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import customAssertions from '../helpers/custom-assertions';

moduleForComponent(
  'full-overlay-verification',
  'Integration | Component | full overlay verification', {
  integration: true,
  beforeEach() {
    customAssertions();
  }
});

test('it renders the question text', function(assert) {
  let question = 'To be or not to be';
  setup(this, {question});
  assert.textPresent(
    '.full-overlay-verification-question',
    question,
    'the question text is present');
});

test('the cancel button', function(assert) {
  assert.expect(2);

  setup(this, {
    cancelText: 'Nope!',
    cancel: function() {
      assert.ok(true, 'Cancel was called.');
    }
  });
  assert.textPresent(
    '.full-overlay-verification-cancel',
    'Nope!',
    'there is a cancel button');
  this.$('.full-overlay-verification-cancel').click();
});

test('the cancel button when no cancel action is set', function(assert) {
  setup(this, {});

  this.$('.full-overlay-verification-cancel').click();
  assert.ok(true, 'Nothing happens');
});

test('the escape key cancels', function(assert) {
  assert.expect(1);
  setup(this, {
    cancel: function() {
      assert.ok(true, 'Cancel was called.');
    }
  });

  var escapeEvent = Ember.$.Event('keyup');
  escapeEvent.which = 27; // # escape key!
  this.$('.full-overlay-verification').trigger(escapeEvent);
});

test('the confirm button', function(assert) {
  assert.expect(2);

  setup(this, {
    confirmText: 'Yep!',
    confirm: function() {
      assert.ok(true, 'Confirm was called.');
    }
  });
  assert.textPresent(
    '.full-overlay-verification-confirm',
    'Yep!',
    'there is a confirm button');
  this.$('.full-overlay-verification-confirm').click();
});


function setup(context, {question, cancel, cancelText, confirm, confirmText}) {
  question = question || 'Are you sure?';
  let template = hbs`{{#full-overlay-verification cancelText=cancelText
                                                  cancel=cancel
                                                  confirmText=confirmText
                                                  confirm=confirm}}
                       {{question}}
                     {{/full-overlay-verification}}`;
  context.set('question', question);
  context.set('cancelText', cancelText);
  context.set('cancel', cancel);
  context.set('confirmText', confirmText);
  context.set('confirm', confirm);
  context.render(template);
}
