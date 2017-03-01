import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import { createCard } from 'tahi/tests/factories/card';
import { createAnswer } from 'tahi/tests/factories/answer';
import registerCustomAssertions from '../helpers/custom-assertions';
import Factory from '../helpers/factory';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

moduleForComponent('billing-task', 'Integration | Component | billing task', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);

    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    $.mockjax({url: '/api/countries', status: 200, responseText: {
      countries: [],
    }});
    $.mockjax({url: '/api/institutional_accounts', status: 200, responseText: {
      institutional_accounts: [],
    }});
    $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
    Factory.createPermission('billingTask', 1, ['edit', 'view']);
  },
  afterEach() {
    $.mockjax.clear();
  }
});

let template = hbs`{{billing-task task=testTask}}`;

let createTask = function(){
  let card = createCard('PlosBilling::BillingTask');
  return make('billing-task', {card: card});
};

// for readability
let createInvalidTask = function(){
  return createTask();
};

let createValidTask = function(){
  let task = createTask();
  fillInBasicBillingInfoForTask(task);
  return task;
};

let fillInBasicBillingInfoForTask = function(task){
  createAnswer(task, 'plos_billing--first_name', { value: 'John' });
  createAnswer(task, 'plos_billing--last_name', { value: 'Doe' });
  createAnswer(task, 'plos_billing--title', { value: 'Prof' });
  createAnswer(task, 'plos_billing--department', { value: 'Fun' });
  createAnswer(task, 'plos_billing--affiliation1', { value: 'Some Uni' });
  createAnswer(task, 'plos_billing--affiliation2', { value: 'Another Uni' });
  createAnswer(task, 'plos_billing--phone_number', { value: '123-335-1223' });
  createAnswer(task, 'plos_billing--email', { value: 'foo@bar.com' });
  createAnswer(task, 'plos_billing--address1', { value: '101 foo st.' });
  createAnswer(task, 'plos_billing--address2', { value: '' });
  createAnswer(task, 'plos_billing--city', { value: 'Columbus' });
  createAnswer(task, 'plos_billing--state', { value: 'OH' });
  createAnswer(task, 'plos_billing--postal_code', { value: 12345 });
  createAnswer(task, 'plos_billing--country', { value: 'USA' });
  createAnswer(task, 'plos_billing--payment_method', { value: 'pfa' });
  createAnswer(task, 'plos_billing--pfa_question_1', { value: true });
  createAnswer(task, 'plos_billing--pfa_question_1a', { value: 'foo' });
  createAnswer(task, 'plos_billing--pfa_question_2', { value: true });
  createAnswer(task, 'plos_billing--pfa_question_2a', { value: '' });
  createAnswer(task, 'plos_billing--pfa_question_3', { value: true });
  createAnswer(task, 'plos_billing--pfa_question_4', { value: true });
  createAnswer(task, 'plos_billing--pfa_amount_to_pay', { value: '99.00' });
  createAnswer(task, 'plos_billing--pfa_supporting_docs', { value: 'foo' });
  createAnswer(task, 'plos_billing--pfa_additional_comments', { value: 'foo' });
  createAnswer(task, 'plos_billing--affirm_true_and_complete', { value: false });
};

test('validates numericality of a few fields', function(assert) {
  let testTask = createValidTask();
  this.set('testTask', testTask);

  this.render(template);

  // filling in a nested question's text input and firing input()
  // will bubble up to the nested question radio, and both will save.
  $.mockjax({url: /\/api\/answers/, type: 'PUT', status: 204});
  $.mockjax({url: /\/api\/answers/, type: 'POST', status: 204});

  // Make the PFA questions invalid
  this.$('input[name=plos_billing--pfa_question_1b]').val('not a number').trigger('input');
  this.$('input[name=plos_billing--pfa_question_2b]').val('not a number').trigger('input');
  this.$('input[name=plos_billing--pfa_question_3a]').val('not a number').trigger('input');
  this.$('input[name=plos_billing--pfa_question_4a]').val('not a number').trigger('input');

  let done = assert.async();
  wait().then(() => {
    assert.textPresent('#error-for-plos_billing--pfa_question_1b', 'Must be a number');
    assert.textPresent('#error-for-plos_billing--pfa_question_2b', 'Must be a number');
    assert.textPresent('#error-for-plos_billing--pfa_question_3a', 'Must be a number');
    assert.textPresent('#error-for-plos_billing--pfa_question_4a', 'Must be a number');
    done();
  });
});

test('it reports validation errors on the task when attempting to complete', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);
  this.$('.billing-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    // Error at the task level
    assert.textPresent('.billing-task', 'Please fix all errors');
    done();
  });
});

test('it does not allow the user to complete when there are validation errors', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);
  this.$('.billing-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.mockjaxRequestNotMade('/api/tasks/1', 'PUT');
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
    done();
  });
});

test('it lets you complete the task when there are no validation errors', function(assert) {
  let testTask = createValidTask();
  this.set('testTask', testTask);

  this.render(template);

  // try to complete
  this.$('.billing-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), true, 'task was completed');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    done();
  });
});

test('it lets you uncomplete the task when it has validation errors', function(assert) {
  let testTask = createInvalidTask();
  this.set('testTask', testTask);

  Ember.run(() => {
    testTask.set('completed', true);
  });

  this.render(template);

  assert.equal(testTask.get('completed'), true, 'task was initially completed');
  this.$('.billing-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task was marked as incomplete');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    $.mockjax.clear();

    // mock the task save again after clearing
    $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
    // try complete again
    this.$('.billing-task button.task-completed').click();

    wait().then(() => {
      assert.textPresent('.billing-task', 'Please fix all errors');
      assert.equal(testTask.get('completed'), false, 'task did not input completion status');
      assert.mockjaxRequestNotMade('/api/tasks/1', 'PUT');
      done();
    });
  });
});
