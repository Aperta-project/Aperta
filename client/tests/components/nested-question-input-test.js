import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import { createQuestion, createQuestionWithAnswer } from 'tahi/tests/factories/nested-question';
import registerCustomAssertions from '../helpers/custom-assertions';
import FakeCanService from '../helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';
moduleForComponent('nested-question-input', 'Integration | Component | nested question input', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    $.mockjax.clear();
    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    this.registry.register('service:can', FakeCanService);

    this.getAnswers = function() {
      return this.container.lookup('service:store').peekAll('nested-question-answer');
    };
  },
});

test('it puts a new answer in the store for unanswered questions, then saves on change', function(assert) {
  let task =  make('ad-hoc-task');
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', task);
  let question = createQuestion(task, 'foo');
  this.set('task', task);
  this.render(hbs`
    {{nested-question-input ident="foo" owner=task}}
  `);

  let newAnswer = this.getAnswers().get('firstObject');
  assert.ok(newAnswer.get('isNew'), 'there is a new answer in the store');
  assert.equal(newAnswer.get('owner.id'), task.id, 'the new answer belongs to the task');
  assert.equal(newAnswer.get('nestedQuestion.id'), question.id, 'the new answer belongs to the question');

  $.mockjax({url: '/api/nested_questions/1/answers', type: 'POST', status: 204, responseText: '{}'});
  let done = assert.async();
  this.$('input').val('new value').trigger('change');
  wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers', 'POST', 'it saves the new answer on change');
    done();
  });
});

test('it saves an existing answer on change', function(assert) {
  let task =  make('ad-hoc-task');
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', task);
  createQuestionWithAnswer(task, 'foo', 'Old Answer');
  this.set('task', task);
  this.render(hbs`
    {{nested-question-input ident="foo" owner=task}}
  `);

  assert.equal(this.$('input').val(), 'Old Answer', 'it renders the answer');

  let answer = this.getAnswers().get('firstObject');
  assert.notOk(answer.get('isNew'), 'the answer is not new');

  $.mockjax({url: '/api/nested_questions/1/answers/1', type: 'PUT', status: 204, responseText: ''});
  let done = assert.async();
  this.$('input').val('new value').trigger('change');
  wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers/1', 'PUT', 'it saves the new answer on change');
    done();
  });
});

test('it deletes and replaces the existing answer on change if the answer is blank', function(assert) {
  let task =  make('ad-hoc-task');
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', task);
  createQuestionWithAnswer(task, 'foo', 'Old Answer');
  this.set('task', task);
  this.render(hbs`
    {{nested-question-input ident="foo" owner=task}}
  `);

  $.mockjax({url: '/api/nested_questions/1/answers/1', type: 'DELETE', status: 204, responseText: ''});
  let done = assert.async();
  this.$('input').val('').trigger('change');
  wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers/1', 'DELETE', 'deletes the blank answer');
    assert.equal(this.getAnswers().get('length'), 1, 'there is only one answer in the store');
    let answer = this.getAnswers().get('firstObject');
    assert.ok(answer.get('isNew'), 'the answer is new');

    $.mockjax.clear();
    $.mockjax({url: '/api/nested_questions/1/answers', type: 'POST', status: 204, responseText: '{}'});

    this.$('input').val('really new answer').trigger('change');
  }).then(wait)
  .then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers', 'POST', 'it saves the new answer on change');
    done();
  });
});
