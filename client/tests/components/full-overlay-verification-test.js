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
  }
);

test('it renders the question text', function(assert) {
  let question = 'To be or not to be';
  setup(this, {
    question: question,
    cancel() {},
    confirm() {},
  });

  assert.textPresent(
    '.full-overlay-verification-question',
    question,
    'the question text is present');
});

test('the cancel button', function(assert) {
  assert.expect(2);

  setup(this, {
    cancelText: 'No',
    cancel() { assert.ok(true, 'Cancel was called.'); },
    confirm() {}
  });
  assert.textPresent(
    '.full-overlay-verification-cancel',
    'No',
    'there is a cancel button');
  this.$('.full-overlay-verification-cancel').click();
});

test('the escape key cancels', function(assert) {
  assert.expect(1);
  setup(this, {
    cancel() { assert.ok(true, 'Cancel was called.'); },
    confirm() {}
  });

  let escapeEvent = Ember.$.Event('keyup');
  escapeEvent.which = 27; // # escape key!
  this.$('.full-overlay-verification').trigger(escapeEvent);
});

test('the confirm button', function(assert) {
  assert.expect(2);

  setup(this, {
    confirmText: 'Yep!',
    cancel() {},
    confirm() { assert.ok(true, 'Confirm was called.'); }
  });
  assert.textPresent(
    '.full-overlay-verification-confirm',
    'Yep!',
    'there is a confirm button');
  this.$('.full-overlay-verification-confirm').click();
});


function setup(context, {question, cancel, cancelText, confirm, confirmText}) {
  question = question || 'Are you sure?';
  context.set('question', question);
  context.set('cancelText', cancelText);
  context.set('cancel', cancel);
  context.set('confirmText', confirmText);
  context.set('confirm', confirm);

  let template = hbs`{{#full-overlay-verification cancelText=cancelText
                                                  cancel=(action cancel)
                                                  confirmText=confirmText
                                                  confirm=(action confirm)}}
                       {{question}}
                     {{/full-overlay-verification}}`;

  context.render(template);
}
