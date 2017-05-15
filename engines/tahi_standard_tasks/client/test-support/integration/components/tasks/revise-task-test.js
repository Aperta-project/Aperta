import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import Factory from '../../../helpers/factory';
import wait from 'ember-test-helpers/wait';

moduleForComponent(
  'revise-task',
  'Integration | Components | Tasks | Revise', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    Factory.createPermission('reviseTask', 1, ['edit', 'view']);
  },
  afterEach() {
    $.mockjax.clear();
  }
});

let createTaskWithDecision = function(decisionAttrs) {
  const decision = make('decision', decisionAttrs);
  return make('revise-task', {
    id: 1,
    paper: { decisions: [decision] }
  });
};

let createTaskWithTwoDecisions = function() {
  const decision1 = make('decision', {authorResponse: null, latestRegistered: true});
  const decision2 = make('decision', {authorResponse: null, latestRegistered: false});
  return make('revise-task', {
    id: 1,
    paper: { decisions: [decision1, decision2] }
  });
};

let createTaskWithoutDecision = function(decisionAttrs) {
  return make('revise-task');
};

let createValidTask = function() {
  return createTaskWithDecision({
    'authorResponse': 'The changes have been made',
    'latestRegistered': true
  });
};

let createInvalidTask = function() {
  return createTaskWithDecision({
    'authorResponse': null,
    'latestRegistered': true
  });
};

let template = hbs`{{revise-task task=testTask}}`;

test('it renders information regarding the latest decision', function(assert) {
  let testTask = createTaskWithDecision({
    'authorResponse': 'The changes have been made',
    'majorVersion': '1',
    'minorVersion': '2',
    'createdAt': new Date('November 29, 2016'),
    'letter': 'This is my letter',
    'latestRegistered': true
  });
  this.set('testTask', testTask);
  this.render(template);

  let done = assert.async();
  wait().then(() => {
    assert.elementsFound('.revise-manuscript-task', 1);
    assert.textPresent('.revise-manuscript-task .decision .revision-number', '1.2', 'revision number was displayed');
    assert.textPresent('.revise-manuscript-task .decision .letter', 'This is my letter', 'letter was displayed');
    assert.textPresent('.revise-manuscript-task .decision .created-at', 'November 29, 2016', 'createdAt date was displayed');
    assert.textPresent('.revise-manuscript-task .author-response', 'The changes have been made', 'author response was displayed');
    done();
  });
});

test('it reports validation errors when there are is no author response or attachment', function(assert) {
  let testTask = createTaskWithoutDecision();
  this.set('testTask', testTask);
  this.render(template);
  this.$('.revise-manuscript-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    // Error at the task level
    assert.textPresent('.revise-manuscript-task', 'Please fix all errors');
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
    done();
  });
});

test('it does not allow the user to complete when there are validation errors', function(assert) {
  let testTask = createTaskWithoutDecision();
  this.set('testTask', testTask);
  this.render(template);
  this.$('.revise-manuscript-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
    done();
  });
});

test('it requires validation on an author response or attachment', function(assert) {
  let testTask = createTaskWithDecision({
    'authorResponse': null,
    'latestRegistered': true
  });
  this.set('testTask', testTask);
  this.render(template);
  this.$('.revise-manuscript-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.textPresent('.response-to-reviewers .error-message:not(.error-message--hidden)', 'Please provide a response or attach a file');
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
    done();
  });
});

test('does not require validation when an attachment is present even if the author response is not present', function(assert) {
  let testTask = createTaskWithDecision({
    'authorResponse': null,
    'latestRegistered': true
  });
  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
  $.mockjax({url: '/api/decisions/1', type: 'GET', status: 200, responseText: '{"decision":{"id":1}}'});
  Ember.run(() => {
    testTask.set('decisions.firstObject.attachments', [make('decision-attachment')]);
  });

  this.set('testTask', testTask);
  this.render(template);
  this.$('.revise-manuscript-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.elementNotFound('.response-to-reviewers .error-message:not(.error-message--hidden)');
    done();
  });
});

test('shows attachments only on associated decisions', function(assert) {
  let testTask = createTaskWithTwoDecisions();
  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
  $.mockjax({url: '/api/decisions/1', type: 'GET', status: 200, responseText: '{"decision":{"id":1}}'});
  $.mockjax({url: '/api/decisions/2', type: 'GET', status: 200, responseText: '{"decision":{"id":2}}'});
  Ember.run(() => {
    testTask.set('decisions.firstObject.attachments', [make('decision-attachment')]);
  });

  this.set('testTask', testTask);
  this.render(template);
  this.$('.decision-bar-bar').each((_, e) => e.click());

  let done = assert.async();
  wait().then(() => {
    assert.equal(this.$('.decision-bar-contents .attachment-file-link').length, 1);
    done();
  });
});

test('it lets you complete the task when there are no validation errors', function(assert) {
  let testTask = createValidTask();
  this.set('testTask', testTask);

  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
  this.render(template);
  this.$('.revise-manuscript-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), true, 'task was completed');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    done();
  });
});

test('it lets you uncomplete the task when it has validation errors', function(assert) {
  let testTask = createInvalidTask()
  this.set('testTask', testTask);

  Ember.run(() => {
    testTask.set('completed', true);
  });

  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
  this.render(template);

  assert.equal(testTask.get('completed'), true, 'task was initially completed');
  this.$('.revise-manuscript-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task was marked as incomplete');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    $.mockjax.clear();

    // make sure we cannot mark it as complete, to ensure it truly was invalid
    this.$('.revise-manuscript-task button.task-completed').click();
    wait().then(() => {
      assert.textPresent('.revise-manuscript-task', 'Please fix all errors');
      assert.equal(testTask.get('completed'), false, 'task did not change completion status');
      assert.mockjaxRequestNotMade('/api/tasks/1', 'PUT');
      done();
    });
  });
});
