import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import Ember from 'ember';
let task;
moduleForComponent('task-disclosure', 'Integration | Component | task disclosure', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);

    task  = FactoryGuy.make('custom-card-task', {
      title: 'Cat',
      viewable: true
    });

    this.set('task', task);
  }
});

test('it renders', function(assert) {
  assert.expect(3);

  this.render(hbs`
    {{#task-disclosure task=task}}
      Meow
    {{/task-disclosure}}
  `);

  assert.equal(
    this.$('.task-disclosure-heading').text().trim(),
    this.get('task.title'),
    'displays a title'
  );

  assert.elementNotFound('.task-disclosure-heading.disabled', 'the card is not disabled when the task is viewable');

  assert.ok(this.$('.task-disclosure').hasClass('task-type-custom-card-task'), 'assigns a custom class');
});

test('it toggles body display', function(assert) {
  assert.expect(2);

  this.render(hbs`
    {{#task-disclosure task=task }}
      Meow
    {{/task-disclosure}}
  `);

  assert.equal(this.$('.task-disclosure-body').length, 0, 'body is hidden');

  this.$('.task-disclosure-heading').click();

  assert.equal(this.$('.task-disclosure-body').length, 1, 'body is displayed');
});

test('it is disabled if the task is not viewable', function(assert) {
  assert.expect(3);
  this.set('task.viewable', false);

  this.render(hbs`
    {{#task-disclosure task=task }}
      Meow
    {{/task-disclosure}}
  `);

  assert.equal(this.$('.task-disclosure-body').length, 0, 'body is hidden');
  assert.elementFound('.task-disclosure-heading.disabled', 'the card is disabled');

  this.$('.task-disclosure-heading').click();

  assert.equal(this.$('.task-disclosure-body').length, 0, 'body remains hidden');

});

test('it displays body if user opted out to preprint', function(assert) {
  this.set('defaultPreprintTaskOpen', true);
  Ember.run(function() {
    task.set('title', 'Preprint Posting');
    task.set('answers', [FactoryGuy.make('answer', {value: false})]);
  });

  this.render(hbs`
    {{#task-disclosure task=task
      defaultPreprintTaskOpen=defaultPreprintTaskOpen }}
      Meow
    {{/task-disclosure}}
  `);

  assert.equal(this.$('.task-disclosure-body').length, 1, 'body is displayed');
});

test('it hides body if user opted in to preprint', function(assert) {
  this.set('defaultPreprintTaskOpen', true);
  Ember.run(function() {
    task.set('title', 'Preprint Posting');
    task.set('answers', [FactoryGuy.make('answer', {value: true})]);
  });
  this.render(hbs`
    {{#task-disclosure task=task
      defaultPreprintTaskOpen=defaultPreprintTaskOpen }}
      Meow
    {{/task-disclosure}}
  `);

  assert.equal(this.$('.task-disclosure-body').length, 0, 'body remains hidden');
});
