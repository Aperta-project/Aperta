import {
  moduleForComponent,
  test
} from 'ember-qunit';

import sinon from 'sinon';

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import customAssertions from '../helpers/custom-assertions';

moduleForComponent('feedback-form', 'Integration | Component | feedback form', {
  integration: true,
  beforeEach() {
    customAssertions();
  }
});


test('it renders the Attach files section by default', function(assert) {
  let template = hbs`{{feedback-form}}`;
  this.render(template);
  assert.elementFound('.fileinput-button', 'displays the input button');

});

test('callers can disable uploads', function(assert) {
  let template = hbs`{{feedback-form allowUploads=false}}`;
  this.render(template);
  assert.elementNotFound('.fileinput-button', 'hides the upload button');
  assert.elementNotFound('.feedback-form-screenshots',
                         'hides the screenshot list entirely');

});

test('it does not render the close button by default', function(assert) {
  let template = hbs`{{feedback-form}}`;
  this.render(template);
  assert.textNotPresent('button', 'cancel');
});

test(
  'it renders the close button when provided with a close action',
  function(assert) {
    let template = hbs`{{feedback-form close=(action actionStub)}}`;
    this.set('actionStub', () => {});
    this.render(template);
    assert.textPresent('button', 'cancel');
});

test(
  'it renders the success checkbox by default',
  function(assert) {
    let template = hbs`{{feedback-form feedbackSubmitted=true}}`;
    this.render(template);
    assert.elementFound('.success-checkmark', 'The success checkmark appears');
});

test(
  'it does not render the success checkbox if showSuccessCheckmark is false',
  function(assert) {
    let template = hbs`{{feedback-form feedbackSubmitted=true
                                       showSuccessCheckmark=false}}`;
    this.render(template);
    assert.elementNotFound(
      '.success-checkmark',
      'The success checkmark does not appear');
});

test('it calls the feedback service on submit', function(assert) {
  let fakeService = {sendFeedback: sinon.stub().returns(Ember.RSVP.resolve())};
  this.set('fakeService', fakeService);
  let template = hbs`{{feedback-form feedbackService=fakeService}}`;
  this.render(template);
  Ember.run(() => {
    this.$('.feedback-form-submit').click();
  });
  assert.spyCalledWith(fakeService.sendFeedback,
                       [window.location.toString(), null, sinon.match.array],
                       'it was called correctly');

  assert.elementFound('.feedback-form-thanks', 'Shows the thank you');
});
