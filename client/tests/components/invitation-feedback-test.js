import Ember from 'ember';
import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import {setRichText} from 'tahi/tests/helpers/rich-text-editor-helpers';

moduleForComponent(
  'invitation-feedback',
  'Integration | Component | invitation feedback',
  {integration: true,
    beforeEach: function() {
      this.set('decline', () => {return;});
      this.set('invitation', Ember.Object.create({
        title: 'Awesome Paper!',
        declineReason: null,
        reviewerSuggestions: null
      }));
    }});

let template = hbs`{{invitation-feedback
                      invitation=invitation
                      decline=(action decline invitation)
                      }}`;

let setThenTest = function (field, text, assertion) {
  setRichText(field, text);
  Ember.run.next(assertion);
};

test('displays paper title', function(assert){
  assert.expect(1);
  this.render(template);
  assert.textPresent('.feedback-invitation-title', 'Awesome Paper!');
});

test('displays an appropriate heading for AEs', function(assert) {
  this.get('invitation').set('academicEditor', true);
  this.render(template);
  assert.textPresent('.feedback-header', 'Academic Editor Invitation Declined');
});

test('displays an appropriate heading for Reviewers', function(assert) {
  this.get('invitation').set('reviewer', true);
  this.render(template);
  assert.textPresent('.feedback-header', 'Reviewer Invitation Declined');
});

test('displays an appropriate alternative suggestion label for AEs', function(assert) {
  this.get('invitation').set('academicEditor', true);
  this.render(template);
  assert.textPresent(
    '.feedback-alternative-suggestions',
    'We would value your suggestions of alternative Academic Editors for this manuscript. ' +
    'Please provide editors’ names, institutions, and email addresses if known.'
  );
});

test('displays an appropriate alternative suggestion label for reviewers', function(assert) {
  this.get('invitation').set('reviewer', true);
  this.render(template);
  assert.textPresent(
    '.feedback-alternative-suggestions',
    'We would value your suggestions of alternative reviewers for this manuscript. ' +
    'Please provide reviewers\' names, institutions, and email addresses if known.'
  );
});

test('can set decline reason', function(assert) {
  let text = 'Too busy!';
  this.render(template);
  setThenTest('declineReason', text, () => {
    assert.equal(this.get('invitation.declineReason'), `<p>${text}</p>`);
  });
});

test('can set reviewer suggestions', function(assert){
  let text = 'Other guy is great';
  this.render(template);
  setThenTest('reviewerSuggestions', text, () => {
    assert.equal(this.get('invitation.reviewerSuggestions'), `<p>${text}</p>`);
  });
});

test('The form is constructed with the expected markup', function(assert){
  assert.expect(4);

  this.render(template);

  assert.selectorHasClasses(
    '.feedback-buttons > .decline-feedback',
    ['button-link', 'button--green']
  );
  assert.selectorHasClasses(
    '.feedback-buttons > .send-feedback',
    ['button-secondary', 'button--green']
  );
});

test('can respond "no thank you" to giving feedback', function(assert){
  assert.expect(2);

  this.set('invitation.declineFeedback', function(){
    assert.ok(true, 'declineFeedback is called on invitation');
  });

  this.set('decline', () => {
    assert.ok(true, 'close action is called when declineFeedback is triggered');
  });

  this.render(template);
  this.$('.feedback-buttons > .decline-feedback').click();
});

test('can Send Feedback', function(assert){
  assert.expect(3);
  this.set('decline', (invitation) => {
    assert.ok(this.get('invitation') === invitation,
      'The invitation object is passed in to the action');

    // assert the values are set on the invitation
    Ember.run.next(() => {
      assert.equal(
        invitation.get('declineReason'),
        '<p>some value</p>',
        'Expected decline reason to be our value'
      );
      assert.equal(
        invitation.get('reviewerSuggestions'),
        '<p>some other value</p>',
        'Expected decline reason to be our other value'
      );
    });
  });

  this.render(template);

  setRichText('declineReason', 'some value');
  setRichText('reviewerSuggestions', 'some other value');

  this.$('.feedback-buttons > .send-feedback').click();
});
