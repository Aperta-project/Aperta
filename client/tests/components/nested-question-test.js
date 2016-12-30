import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../helpers/custom-assertions';
import wait from 'ember-test-helpers/wait';
import { createQuestion, createQuestionWithAnswer } from 'tahi/tests/factories/nested-question';
import Ember from 'ember';

/*
 * This set of tests are more like unit tests for the nested-question component,
 * but due to the number of collaborators involved and how important it is to get
 * the actual behavior of those collaborators right (nested-question's answerForOwner, etc)
 * and how much of a pain it would be to do a `needs: [foo:bar]` statement for those things,
 * I've made this a component integration test instead.
 * */

moduleForComponent('nested-question', 'Integration | Component | nested question', {
  integration: true,
  beforeEach() { registerCustomAssertions();
    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    manualSetup(this.container);
  },
  afterEach() {
    $.mockjax.clear();
  }
});

let template = hbs`
{{#nested-question
  ident="foo"
  owner=task
  decision=decision
  additionalData=additionalData
  as |q|}}
  <span class="question-text">
    {{if q.question q.question.text "no question"}}
  </span>
  {{#if q.answer}}
    {{input class="answer-value" value=q.answer.value}}
  {{else}}
    <span class="no-answer"> No answer</span>
  {{/if}}
  <button {{action q.save}}>Save</button>
{{/nested-question}}
`;

test('finds its question by ident and owner', function(assert) {
  // question is null if owner is null
  this.render(template);
  assert.textPresent('.question-text', 'no question', 'question is null if owner is null');
  let task = make('ad-hoc-task');
  let question = createQuestion(task, 'foo', 'question text');

  this.set('task', task);
  assert.textPresent('.question-text', 'question text', 'yields the question');
  this.set('additionalData', 'additional test data');
  assert.equal(
    question.get('additionalData'),
    'additional test data',
    `nested-question sets the additionalData on the question it
    finds if provided`
  );

});

test('finds its answer by ident, owner, and decision', function(assert) {
  // answer is null if owner is null
  // finds answer based on decision
  this.render(template);
  assert.elementFound('.no-answer', 'answer is null if owner is null');
  let task = make('ad-hoc-task');
  createQuestionWithAnswer(
    task,
    {ident: 'foo', text: 'test text'},
    'test answer'
  );
  this.set('task', task);
  assert.equal(
    this.$('.answer-value').val(),
    'test answer',
    'it yields the answer');
});

test('saves the answer on change events', function(assert) {
  let task = make('ad-hoc-task');
  createQuestionWithAnswer(task, 'foo', 'test answer');
  this.set('task', task);
  let template = hbs`
  {{#nested-question ident="foo" owner=task as |q|}}
    {{input class="answer-value" value=q.answer.value}}
  {{/nested-question}}
  `;

  $.mockjax({url: '/api/nested_questions/1/answers/1', type: 'PUT', status: 204, responseText: ''});
  this.render(template);
  this.$('.answer-value').change();
  return wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers/1', 'PUT', 'it saves the new answer on change');
  });
});

test('save action validates and then saves the answer', function(assert) {
  assert.expect(3);
  let task = make('ad-hoc-task');
  createQuestionWithAnswer(task, 'foo', 'test answer');
  this.set('task', task);
  this.set('validateStub', (ident, val) => {
    assert.equal(ident, 'foo');
    assert.equal(val, 'test answer');
  });
  let template = hbs`
  {{#nested-question
    ident="foo"
    validate=(action validateStub)
    owner=task as |q|}}
    {{input class="answer-value" value=q.answer.value}}
    <button {{action q.save}}>Save</button>
  {{/nested-question}}
  `;

  $.mockjax({url: '/api/nested_questions/1/answers/1', type: 'PUT', status: 204, responseText: ''});
  this.render(template);
  this.$('button').click();
  return wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers/1', 'PUT', 'it saves the new answer on change');
  });
});

test(
  `if the answer is deleted, nested-question will create
  a new blank answer in the store and display it`
, function(assert) {
  // assert that there's a different answer in the template than the
  // original one
  let task = make('ad-hoc-task');
  createQuestionWithAnswer(task, 'foo', 'test answer');
  this.set('task', task);
  let template = hbs`
  {{#nested-question
    ident="foo"
    owner=task as |q|}}
    <span class="answer-is-new">{{q.answer.isNew}}</span>
    {{input class="answer-value" value=q.answer.value}}
  {{/nested-question}}
  `;
  $.mockjax({url: '/api/nested_questions/1/answers/1', type: 'DELETE', status: 204, responseText: ''});
  this.render(template);
  assert.textPresent('.answer-is-new', 'false');
  this.$('.answer-value').val('').change();
  return wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers/1', 'DELETE', 'it deletes the answer');
    assert.textPresent('.answer-is-new', 'true');
    $.mockjax({url: '/api/nested_questions/1/answers', type: 'POST', status: 204, responseText: '{}'});
    this.$('.answer-value').val('new answer').change();
  }).then(wait).then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers', 'POST', 'it saves the new answer');
  });

});


let questionTemplate = hbs`
{{#nested-question
  ident="foo"
  displayQuestionText=displayQuestionText
  displayQuestionAsPlaceholder=displayQuestionAsPlaceholder
  owner=task as |q|}}
  <span class="should-display">{{q.shouldDisplayQuestionText}}</span>
{{/nested-question}}
`;
test('yields shouldDisplayQuestionText #1', function(assert) {
  let task = make('ad-hoc-task');
  let question = createQuestion(task, 'foo', 'question text');

  this.setProperties({
    task: task,
    displayQuestionText: false,
    displayQuestionAsPlaceholder: false
  });
  this.render(questionTemplate);
  assert.textPresent('.should-display', 'false', 'aliases displayQuestionText');
});

test('yields shouldDisplayQuestionText #2', function(assert) {
  let task = make('ad-hoc-task');
  let question = createQuestion(task, 'foo', 'question text');

  this.setProperties({
    task: task,
    displayQuestionText: true,
    displayQuestionAsPlaceholder: false
  });
  this.render(questionTemplate);

  assert.textPresent('.should-display', 'true',  'can be set directly by passing in displayQuestionText');

});

test('yields shouldDisplayQuestionText #3', function(assert) {
  let task = make('ad-hoc-task');
  let question = createQuestion(task, 'foo', 'question text');

  this.setProperties({
    task: task,
    displayQuestionText: true,
    displayQuestionAsPlaceholder: true
  });

  this.render(questionTemplate);
  this.set('displayQuestionAsPlaceholder', true);
  return wait().then(() => {
    assert.textPresent('.should-display', 'false', 'false if displayQuestionAsPlaceholder is true, even if displayQuestionText is true');
  });
});

test('yields placeholderText', function(assert) {
  let task = make('ad-hoc-task');
  let question = createQuestion(task, 'foo', 'question text');

  this.set('task', task);
  let template = hbs`
  {{#nested-question
    ident="foo"
    placeholder="static text"
    displayQuestionAsPlaceholder=displayQuestionAsPlaceholder
    owner=task as |q|}}
    <span class="placeholder-text">{{q.placeholderText}}</span>
  {{/nested-question}}
  `;
  this.setProperties({
    displayQuestionAsPlaceholder: false
  });
  this.render(template);

  assert.textPresent('.placeholder-text', 'static text', 'yields the provided placeholder as placeholderText');
});

test('yields question text as placeholderText', function(assert) {
  let task = make('ad-hoc-task');
  let question = createQuestion(task, 'foo', 'question text');

  this.set('task', task);
  let template = hbs`
  {{#nested-question
    ident="foo"
    placeholder="static text"
    displayQuestionAsPlaceholder=displayQuestionAsPlaceholder
    owner=task as |q|}}
    <span class="placeholder-text">{{q.placeholderText}}</span>
  {{/nested-question}}
  `;

  this.setProperties({
    displayQuestionAsPlaceholder: true
  });
  this.render(template);
  assert.textPresent('.placeholder-text', 'question text', 'yields question text as placeholder if displayQuestionAsPlaceholder');
});
