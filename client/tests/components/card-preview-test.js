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

test('no delete button display for reviewer card, even if canRemoveCard is true', function(assert) {
  this.set('task', {
    title: 'Review by Reviewer User',
    type: 'ReviewerReportTask',
  });
  assert.expect(2);

  this.render(hbs`
    {{card-preview task=task canRemoveCard=true}}
  `);

  Ember.run(this, function() {
    assert.textPresent('span.card-title', 'Review by Reviewer User');
    assert.equal(this.$('.task-disclosure-heading .card-remove').length, 0);
  });
});

test('no delete button display for Front Matter reviewer card, even if canRemoveCard is true', function(assert) {
  this.set('task', {
    title: 'Review by Reviewer User',
    type: 'FrontMatterReviewerReportTask',
  });
  assert.expect(2);

  this.render(hbs`
    {{card-preview task=task canRemoveCard=true}}
  `);

  Ember.run(this, function() {
    assert.textPresent('span.card-title', 'Review by Reviewer User');
    assert.equal(this.$('.task-disclosure-heading .card-remove').length, 0);
  });
});

test('delete button display for any other type of task', function(assert) {
  this.set('task', {
    type: 'AuthorsTask',
  });
  assert.expect(1);

  this.render(hbs`
    {{card-preview task=task canRemoveCard=true}}
  `);
  
  Ember.run(this, function() {
    assert.equal(this.$('.task-disclosure-heading .card-remove').length, 1);
  });
});

test('is disabled when the task is not viewable', function(assert) {
  this.set('task', {
    viewable: false,
  });
  assert.expect(1);

  this.render(hbs`
    {{card-preview taskTemplate=taskTemplate task=task}}
  `);

  assert.equal(this.$('.task-disclosure-heading.disabled').length, 1);
});

test('is not disabled when the task is viewable', function(assert) {
  this.set('task', {
    viewable: true,
  });
  assert.expect(1);

  this.render(hbs`
    {{card-preview taskTemplate=taskTemplate task=task}}
  `);

  assert.equal(this.$('.task-disclosure-heading.disabled').length, 0);
});

test('is not disabled when displaying a taskTemplate (as in the MMT Workflow admin screen', function(assert) {
  this.set('task', {
    viewable: false,
  });
  this.set('taskTemplate', {
    foo: 'bar',
  });
  assert.expect(1);

  this.render(hbs`
    {{card-preview taskTemplate=taskTemplate task=task}}
  `);

  assert.equal(this.$('.task-disclosure-heading.disabled').length, 0);
});
