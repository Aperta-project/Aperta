import Ember from 'ember';
import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('reviewer-invitation-feedback',
                   'Integration | Component | reviewer invitation feedback',
                   {integration: true,
                    beforeEach: function() {
                      this.set('update', () => {return;});
                      this.set('close', () => {return;});
                      this.set('invitation', Ember.Object.create({
                        title: 'Awesome Paper!',
                        declineReason: null,
                        reviewerSuggestions: null
                      }));
                    }});

var template = hbs`{{reviewer-invitation-feedback
                      invitation=invitation
                      close=(action close)
                      update=(action update invitation)
                      }}`;

var fillText = function(selector, text) {
  this.$(selector).val(text);
  this.$(selector).change();
};

test('displays paper title', function(assert){
  assert.expect(1);

  this.render(template);
  assert.textPresent('.feedback-invitation-title', 'Awesome Paper!');
});

test('can set decline reason', function(assert){
  assert.expect(1);

  this.render(template);
  fillText('textarea[name="declineReason"]', 'Too busy!');

  assert.equal(this.get('invitation.declineReason'), 'Too busy!');
});

test('can set reviewer suggestions', function(assert){
  assert.expect(1);

  this.render(template);
  fillText('textarea[name="reviewerSuggestions"]', 'Other guy is great');

  assert.equal(
    this.get('invitation.reviewerSuggestions'),
    'Other guy is great'
  );
});

test('The form is constructed with the expected markup', function(assert){
  assert.expect(7);

  this.render(template);
  assert.equal(this.$('textarea').length,
               2, 'there are 2 textareas');
  assert.selectorHasClasses('label>textarea', ['feedback-textarea']);
  assert.selectorHasClasses(
    '.reviewer-feedback-buttons > .reviewer-decline-feedback',
    ['button-link', 'button--green']
  );
  assert.selectorHasClasses(
    '.reviewer-feedback-buttons > .reviewer-send-feedback',
    ['button-secondary', 'button--green']
  );
});

test('can respond "no thank you" to giving feedback', function(assert){
  assert.expect(4);
  this.set('close', () => {

    // assert the values were cleared on the invitation
    assert.equal(this.get('invitation.declineReason'),
                 null,
                 'Expected decline reason to be blank'
    );
    assert.equal(this.get('invitation.reviewerSuggestions'),
                 null,
                 'Expected decline reason to be blank'
    );
  });

  this.render(template);

  fillText('textarea[name="declineReason"]', 'some value');
  fillText('textarea[name="reviewerSuggestions"]', 'some other value');

  // assert the values were actually set on the invitation
  assert.equal(this.get('invitation.declineReason'),
               'some value',
               'Expected declineReason to be some value'
  );
  assert.equal(this.get('invitation.reviewerSuggestions'),
               'some other value',
               'Expected reviewerSuggestions to be some other value'
  );

  this.$('.reviewer-feedback-buttons > .reviewer-decline-feedback').click();
});

test('can Send Feedback', function(assert){
  assert.expect(3);
  this.set('update', (invitation) => {
    assert.ok(this.get('invitation')===invitation,
      'The invitation object is passed in to the action');

    // assert the values are set on the invitation
    assert.equal(invitation.get('declineReason'),
                'some value',
                'Expected decline reason to be our value'
    );
    assert.equal(invitation.get('reviewerSuggestions'),
                'some other value',
                'Expected decline reason to be our other value'
    );
  });

  this.render(template);

  fillText('textarea[name="declineReason"]', 'some value');
  fillText('textarea[name="reviewerSuggestions"]', 'some other value');

  this.$('.reviewer-feedback-buttons > .reviewer-send-feedback').click();
});
