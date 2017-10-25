import {moduleFor, moduleForComponent, test} from 'ember-qunit';
import { make, manualSetup, mockCreate } from 'ember-data-factory-guy';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('custom-card-task', 'Integration | Components | Card Content', {
  integration: true,

  beforeEach() {
    this.registry.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
    manualSetup(this.container);
    this.registry.register('service:can', FakeCanService);

    let task = make('custom-card-task');
    this.set('task', task);
  }
});

test('it creates an answer for card-content', function(assert) {

  // add a single piece of answerable card content to work with
  let cardContent = make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);
  mockCreate('answer');

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);

  assert.elementsFound('input.form-control', 1);
  this.$('input.form-control').val('a new answer').trigger('input').blur();

  return wait().then(() => {
    assert.mockjaxRequestMade('/api/answers', 'POST');
    $.mockjax.clear();
  });
});

test('it does not create an answer for non answerables', function(assert) {

  // add a single piece of non-answerable card content to work with
  let cardContent = make('card-content', 'description');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);
  assert.equal(this.get('task.cardVersion.contentRoot.answers.length'), 0, 'there are no answers for a paragraph tag');
});

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
  let component = this.subject({content: cardContent, owner: task, preview: false});

  assert.notOk(component.shouldEagerlySave(answer));
});

test('it eagerly saves new required answers', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: true });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);
  let answer = cardContent.answerForOwner(task);
  let component = this.subject({content: cardContent, owner: task, preview: false});

  assert.ok(component.shouldEagerlySave(answer));
});

test('it eagerly saves new answers with default values', function(assert) {
  let cardContent = make('card-content', 'shortInput', { defaultAnswerValue: 'hippopotamus' });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);

  let answer = cardContent.answerForOwner(task);
  assert.equal(answer.get('value'), 'hippopotamus');

  let component = this.subject({content: cardContent, owner: task, preview: false});
  assert.ok(component.shouldEagerlySave(answer));
});
