import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('token-invitation', 'Integration | Component | token invitation', {
  integration: true,
  beforeEach() {
    this.set('declineDone', false);
    this.set('model', Ember.Object.create({
      token: 'abc',
      save: function() { return Ember.RSVP.resolve(); },
      setDeclined: function() {}
    }));
  }
});

let template = hbs `{{token-invitation model=model declineDone=declineDone}}`;

test('displays inactive message if already declined', function(assert){
  this.render(template);

  assert.elementFound('.message.inactive', 'Displays inactive message');
  assert.elementNotFound('.message.thankyou', 'Does not display thank you message');
});

test('displays inactive message if already declined', function(assert){
  this.set('declineDone', true);
  this.render(template);

  assert.elementFound('.message.thankyou', 'Displays thank you message');
});

test('displays invitations-x component when invited', function(assert){
  this.set('model.pendingFeedback', true);
  this.render(template);
  assert.elementFound('.dashboard-open-invitations', 'Displays invitation');
});

test('Buttons trigger saves, resulting in thank you message', function(assert) {
  assert.expect(3);
  this.set('model.pendingFeedback', false);
  this.set('model.invited', true);
  this.set('model.save', function() {
    assert.ok(true, 'Model is saved on decline and submit feedback button click');
    return Ember.RSVP.resolve();
  });
  this.render(template);
  this.$('.invitation-decline').click(); // acquire feedback
  this.$('.send-feedback').click();
  assert.elementFound('.message.thankyou', 'Displays thank you message');
});
