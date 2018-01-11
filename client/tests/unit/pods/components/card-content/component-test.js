import {moduleFor,  test} from 'ember-qunit';
import {make, manualSetup } from 'ember-data-factory-guy';

moduleFor('component:card-content', 'Unit: Card Content Component', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
  }
});

test('it lazily saves new answers', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: false, defaultAnswerValue: null });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);
  let answer = cardContent.answerForOwner(task);
  let component = this.subject({content: cardContent, owner: task, preview: false, repetition: null});

  assert.notOk(component.shouldEagerlySave(answer));
});

test('it eagerly saves new required answers', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: true });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);
  let answer = cardContent.answerForOwner(task);
  let component = this.subject({content: cardContent, owner: task, preview: false, repetition: null});

  assert.ok(component.shouldEagerlySave(answer));
});

test('it eagerly saves new answers with default values', function(assert) {
  let cardContent = make('card-content', 'shortInput', { defaultAnswerValue: 'hippopotamus' });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);

  let answer = cardContent.answerForOwner(task);
  assert.equal(answer.get('value'), 'hippopotamus');

  let component = this.subject({content: cardContent, owner: task, preview: false, repetition: null});
  assert.ok(component.shouldEagerlySave(answer));
});
