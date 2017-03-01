import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import { createAnswer } from 'tahi/tests/factories/answer';
import registerCustomAssertions from '../helpers/custom-assertions';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';
moduleForComponent('nested-question-input', 'Integration | Component | nested question input', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));

    this.getAnswers = function() {
      return this.container.lookup('service:store').peekAll('answer');
    };

    this.question = make('card-content', { ident: 'foo' });
  },

  afterEach() {
    $.mockjax.clear();
  }
});

let setValue = ($input, newVal) => {
  return $input.val(newVal).trigger('input');
};

let template = hbs`{{nested-question-input ident="foo" owner=task}}`;
test('it puts a new answer in the store for unanswered questions, then saves on input', function(assert) {
  let task =  make('ad-hoc-task');

  this.set('task', task);
  this.render(template);

  let newAnswer = this.getAnswers().get('firstObject');
  assert.ok(newAnswer.get('isNew'), 'there is a new answer in the store');
  assert.equal(newAnswer.get('owner.id'), task.id, 'the new answer belongs to the task');
  assert.equal(newAnswer.get('cardContent.id'), this.question.id, 'the new answer belongs to the question');

  $.mockjax({url: '/api/answers', type: 'POST', status: 201, responseText: '{}'});
  setValue(this.$('input'), 'new value');
  return wait().then(() => {
    assert.mockjaxRequestMade('/api/answers', 'POST', 'it saves the new answer on change');
  });
});

test('it saves an existing answer on input', function(assert) {
  let task =  make('ad-hoc-task');
  createAnswer(task, 'foo', { value: 'Old Answer' });
  this.set('task', task);
  this.render(template);

  assert.equal(this.$('input').val(), 'Old Answer', 'it renders the answer');

  let answer = this.getAnswers().get('firstObject');
  assert.notOk(answer.get('isNew'), 'the answer is not new');

  $.mockjax({url: '/api/answers/1', type: 'PUT', status: 204, responseText: ''});
  setValue(this.$('input'), 'new value');
  return wait().then(() => {
    assert.mockjaxRequestMade('/api/answers/1', 'PUT', 'it saves the new answer on change');
  });
});

test('it deletes and replaces the existing answer on input if the answer is blank', function(assert) {
  let task =  make('ad-hoc-task');
  createAnswer(task, 'foo', { value: 'Old Answer' });
  this.set('task', task);
  this.render(template);

  $.mockjax({url: '/api/answers/1', type: 'DELETE', status: 204, responseText: ''});
  setValue(this.$('input'), '');
  return wait().then(() => {
    assert.mockjaxRequestMade('/api/answers/1', 'DELETE', 'deletes the blank answer');
    assert.equal(this.getAnswers().get('length'), 1, 'there is only one answer in the store');
    let answer = this.getAnswers().get('firstObject');
    assert.ok(answer.get('isNew'), 'the answer is new');

    $.mockjax.clear();
    $.mockjax({url: '/api/answers', type: 'POST', status: 204, responseText: '{}'});

    setValue(this.$('input'), 'really new answer');
  }).then(wait)
  .then(() => {
    assert.mockjaxRequestMade('/api/answers', 'POST', 'it saves the new answer on change');
  });
});

test('it does not render when the type is invalid', function(assert) {
  let task =  make('ad-hoc-task');
  this.set('task', task);
  return assert.throws(() => {
    this.render(hbs`
      {{nested-question-input ident="foo" owner=task type="radio"}}
    `);
  });
});
