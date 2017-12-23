import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('co-authors', 'Integration | Component | co authors', {
  integration: true
});

test('it renders the paper title when the author is confirmable', function(assert) {
  this.set('model', {isConfirmable: true, paperTitle: 'Some title'});
  this.render(hbs`{{co-authors author=model}}`);
  
  assert.textPresent(this.$('.co-author-confirmation'), 'Some title');
});

test('it renders "Thank You" when the author is confirmed', function(assert) {
  this.set('model', {isConfirmed: true, paperTitle: 'Some title'});
  this.render(hbs`{{co-authors author=model}}`);
  
  assert.textPresent(this.$('.co-author-confirmation'), 'Thank You!');
  assert.textNotPresent(this.$('.co-author-confirmation'), 'Some title');
});
