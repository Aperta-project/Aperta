import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('co-authors', 'Integration | Component | co authors', {
  integration: true
});

test('it renders a coauthorship confirmation form when the author is confirmable', function(assert) {
  this.set('model', {confirmationState: 'unconfirmed', paperTitle: 'Some title', createdAt: new Date('10/3/2013')});
  this.render(hbs`{{co-authors author=model}}`);
  
  assert.textPresent(this.$('.dashboard-paper-title'), 'Some title');
  assert.textPresent(this.$('.confirmation-metadata .date'), 'Oct 3, 2013');
  assert.textNotPresent(this.$('.message.thank-you'), 'Thank You!');
});

test('it renders "Thank You" when the author is confirmed', function(assert) {
  this.set('model', {confirmationState: 'confirmed', paperTitle: 'Some title', createdAt: new Date('10/3/2013')});
  this.render(hbs`{{co-authors author=model}}`);
  
  assert.textNotPresent(this.$('.dashboard-paper-title'), 'Some title');
  assert.textNotPresent(this.$('.confirmation-metadata .date'), 'Oct 3, 2013');
  assert.textPresent(this.$('.message.thank-you'), 'Thank You!');
});

test('it renders blank when the authorship is refuted', function(assert) {
  this.set('model', {confirmationState: 'refuted', paperTitle: 'Some title', createdAt: new Date('10/3/2013')});
  this.render(hbs`{{co-authors author=model}}`);

  assert.textNotPresent(this.$('.dashboard-paper-title'), 'Some title');
  assert.textNotPresent(this.$('.confirmation-metadata .date'), 'Oct 3, 2013');
  assert.textNotPresent(this.$('.message.thank-you'), 'Thank You!');
});
