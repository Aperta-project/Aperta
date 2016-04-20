import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('card-preview', 'Integration | Component | card preview', {
  integration: true,

  beforeEach() {
    this.set('task', {
      title: 'Example Card',
      commentLooks: [{}, {}]
    });
  }
});

test('task is required', function(assert) {
  assert.expect(1);

  assert.throws(function() {
    this.render(hbs`
      {{card-preview}}
    `);
  }, Error, 'has thrown an Error');
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{card-preview task=task}}
  `);

  assert.equal(this.$('.card').length, 1);
});

test('#unread-comments-count badge displays when there are commentLooks', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{card-preview task=task}}
  `);

  assert.equal(this.$('.unread-comments-count').text(), '2', 'correct badge count');
});

test('#unread-comments-count badge is removed when commentLooks are "read"', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{card-preview task=task}}
  `);

  Ember.run(this, function() {
    this.set('task.commentLooks', []);
    assert.equal(this.$('.unread-comments-count').length, 0, 'badge is not displayed');
  });
});
