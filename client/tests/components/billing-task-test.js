import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../helpers/custom-assertions';
import FakeCanService from '../helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';
moduleForComponent('billing-task', 'Integration | Component | billing task', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
  }
});

let template = hbs`{{billing-task
                      task=task}}`;


let createQA = (task, ident, answerValue) => {
  let answer = make('nested-question-answer', {value: answerValue, owner: task});
  let question = make('nested-question', {
    ident: ident,
    answers: [answer],
    owner: task
  });

  task.get('nestedQuestions').addObject(question);
};

let createQuestion = (task, ident) => {
  let question = make('nested-question', {
    ident: ident,
    owner: task
  });

  task.get('nestedQuestions').addObject(question);
};

test('validates numericality of a few fields', function(assert) {
  this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
  this.registry.register('service:can', FakeCanService);
  $.mockjax({url: '/api/countries', status: 200, responseText: {
    countries: [],
  }});
  $.mockjax({url: '/api/institutional_accounts', status: 200, responseText: {
    institutional_accounts: [],
  }});

  let task =  make('billing-task');
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', task);

  // all nested questions referenced in the hbs template must
  // exist, but they don't have to have answers.  I've put them
  // in for kicks.

  createQA(task, 'plos_billing--first_name', 'John');
  createQA(task, 'plos_billing--last_name', 'Doe');
  createQA(task, 'plos_billing--title', 'Prof');
  createQA(task, 'plos_billing--department', 'Fun');
  createQA(task, 'plos_billing--affiliation1', 'Some Uni');
  createQA(task, 'plos_billing--affiliation2', 'Another Uni');
  createQA(task, 'plos_billing--phone_number', '123-335-1223');
  createQA(task, 'plos_billing--email', 'foo@bar.com');
  createQA(task, 'plos_billing--address1', '101 foo st.');
  createQA(task, 'plos_billing--address2', '');
  createQA(task, 'plos_billing--city', 'Columbus');
  createQA(task, 'plos_billing--state', 'OH');
  createQA(task, 'plos_billing--postal_code', 12345);
  createQA(task, 'plos_billing--country', 'USA');
  createQA(task, 'plos_billing--payment_method', 'pfa');
  createQA(task, 'plos_billing--pfa_question_1', true);
  createQA(task, 'plos_billing--pfa_question_1a', 'foo');
  createQA(task, 'plos_billing--pfa_question_2', true);
  createQA(task, 'plos_billing--pfa_question_2a', '');
  createQA(task, 'plos_billing--pfa_question_3', true);
  createQA(task, 'plos_billing--pfa_question_4', true);
  createQA(task, 'plos_billing--pfa_amount_to_pay', 'foo');
  createQA(task, 'plos_billing--pfa_supporting_docs', 'foo');
  createQA(task, 'plos_billing--pfa_additional_comments', 'foo');
  createQA(task, 'plos_billing--affirm_true_and_complete', false);

  // these fields have PFA validation, which we'll test
  createQuestion(task, 'plos_billing--pfa_question_1b');
  createQuestion(task, 'plos_billing--pfa_question_2b');
  createQuestion(task, 'plos_billing--pfa_question_3a');
  createQuestion(task, 'plos_billing--pfa_question_4a');

  this.set('task', task);
  this.render(template);

  // filling in a nested question's text input and firing change()
  // will bubble up to the nested question radio, and both will save.
  $.mockjax({url: /\/api\/nested_questions/, type: 'PUT', status: 204});
  $.mockjax({url: /\/api\/nested_questions/, type: 'POST', status: 204});

  this.$('input[name=plos_billing--pfa_question_1b]').val('not a number').change();
  this.$('input[name=plos_billing--pfa_question_2b]').val('not a number').change();
  this.$('input[name=plos_billing--pfa_question_3a]').val('not a number').change();
  this.$('input[name=plos_billing--pfa_question_4a]').val('not a number').change();
  let done = assert.async();
  wait().then(() => {
    assert.textPresent('#error-for-plos_billing--pfa_question_1b', 'Must be a number');
    assert.textPresent('#error-for-plos_billing--pfa_question_2b', 'Must be a number');
    assert.textPresent('#error-for-plos_billing--pfa_question_3a', 'Must be a number');
    assert.textPresent('#error-for-plos_billing--pfa_question_4a', 'Must be a number');
    done();
  });
});
