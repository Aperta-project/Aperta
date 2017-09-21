import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';

moduleForComponent('task-disclosure', 'Integration | Component | task disclosure', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);

    let task  = FactoryGuy.make('task', {
      title: 'Cat',
      type: 'TabbyCat',
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

  assert.elementNotFound('.task-disclosure-heading.disabled', 'the card is not disabled');

  assert.ok(this.$('.task-disclosure').hasClass('task-type-tabby-cat'));
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
