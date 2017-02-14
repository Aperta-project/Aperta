import { test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { make } from 'ember-data-factory-guy';
import moduleForComponentIntegration from 'tahi/tests/helpers/module-for-component-integration';
moduleForComponentIntegration('nested-question-input', {
  beforeEach() {
    this.getAnswers = function() {
      return this.container.lookup('service:store').peekAll('nested-question-answer');
    };
  }
});

let setValue = ($input, newVal) => {
  return $input.val(newVal).trigger('input');
};

test('it puts a new answer in the store for unanswered questions, then saves on input', function(assert) {
  let task =  make('ad-hoc-task');
  this.fakeCan.allowPermission('edit', task);
  let question = this.createQuestion(task, 'foo');
  this.set('task', task);
  this.render(hbs`
    {{nested-question-input ident="foo" owner=task}}
  `);

  let newAnswer = this.getAnswers().get('firstObject');
  assert.ok(newAnswer.get('isNew'), 'there is a new answer in the store');
  assert.equal(newAnswer.get('owner.id'), task.id, 'the new answer belongs to the task');
  assert.equal(newAnswer.get('nestedQuestion.id'), question.id, 'the new answer belongs to the question');

  $.mockjax({url: '/api/nested_questions/1/answers', type: 'POST', status: 204, responseText: '{}'});
  setValue(this.$('input'), 'new value');
  return this.wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers', 'POST', 'it saves the new answer on change');
  });
});

test('it saves an existing answer on input', function(assert) {
  let task =  make('ad-hoc-task');
  this.fakeCan.allowPermission('edit', task);
  this.createQuestionWithAnswer(task, 'foo', 'Old Answer');
  this.set('task', task);
  this.render(hbs`
    {{nested-question-input ident="foo" owner=task}}
  `);

  assert.equal(this.$('input').val(), 'Old Answer', 'it renders the answer');

  let answer = this.getAnswers().get('firstObject');
  assert.notOk(answer.get('isNew'), 'the answer is not new');

  $.mockjax({url: '/api/nested_questions/1/answers/1', type: 'PUT', status: 204, responseText: ''});
  setValue(this.$('input'), 'new value');
  return this.wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers/1', 'PUT', 'it saves the new answer on change');
  });
});

test('it deletes and replaces the existing answer on input if the answer is blank', function(assert) {
  let task =  make('ad-hoc-task');
  this.fakeCan.allowPermission('edit', task);
  this.createQuestionWithAnswer(task, 'foo', 'Old Answer');
  this.set('task', task);
  this.render(hbs`
    {{nested-question-input ident="foo" owner=task}}
  `);

  $.mockjax({url: '/api/nested_questions/1/answers/1', type: 'DELETE', status: 204, responseText: ''});
  setValue(this.$('input'), '');
  return this.wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers/1', 'DELETE', 'deletes the blank answer');
    assert.equal(this.getAnswers().get('length'), 1, 'there is only one answer in the store');
    let answer = this.getAnswers().get('firstObject');
    assert.ok(answer.get('isNew'), 'the answer is new');

    $.mockjax.clear();
    $.mockjax({url: '/api/nested_questions/1/answers', type: 'POST', status: 204, responseText: '{}'});

    setValue(this.$('input'), 'really new answer');
  }).then(this.wait)
  .then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers', 'POST', 'it saves the new answer on change');
  });
});

test('it does not render when the type is invalid', function(assert) {
  let task =  make('ad-hoc-task');
  this.fakeCan.allowPermission('edit', task);
  this.createQuestionWithAnswer(task, 'foo', 'Old Answer');
  this.set('task', task);
  return assert.throws(() => {
    this.render(hbs`
      {{nested-question-input ident="foo" owner=task type="radio"}}
    `);
  });
});
