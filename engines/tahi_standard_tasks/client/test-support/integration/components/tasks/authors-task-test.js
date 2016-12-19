import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import Factory from '../../../helpers/factory';
import wait from 'ember-test-helpers/wait';

moduleForComponent(
  'authors-task',
  'Integration | Components | Tasks | Authors', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    Factory.createPermission('authorsTask', 1, ['edit', 'view']);

    // For any answers that will be sent to the server
    $.mockjax({url: /api\/nested_questions\/\d+\/answers/, status: 204});
  },
  afterEach() {
    $.mockjax.clear();
  }
});

let createTask = function() {
  let task = make('authors-task', {
    id: 1,
    paper: { authors: [] }
  });
  return task;
}

let createTaskWithInvalidAuthor = function() {
  let task = make('authors-task', {
    id: 1,
    paper: { authors: [make('author')] }
  });
  return task;
}


let template = hbs`{{authors-task task=testTask}}`;
let errorSelector = '.authors-task .error-message:not(.error-message--hidden)'

test('it renders the paper\'s authors', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);

  let done = assert.async();
  wait().then(() => {
    assert.elementsFound('.authors-task', 1);
    done();
  });
});

test('it reports validation errors on the task when attempting to complete', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);
  this.$('.authors-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    // Error at the task level
    assert.textPresent('.authors-task', 'Please fix all errors');
    done();
  });
});

test('it does not allow the user to complete when there are validation errors', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);
  this.$('.authors-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
    done();
  });
});

test('it requires validation on the user confirming authors agree to being named', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);

  // Make sure the other answers are checked
  this.$('.authors-task input[name="authors--authors_confirm_icmje_criteria"]').click();
  this.$('.authors-task input[name="authors--authors_agree_to_submission"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.textPresent(
      '.authors-task .authors-task-acknowledgements .error-message:not(.error-message--hidden)',
      'Please acknowledge the statements below'
    );
    done();
  });
});

test('it requires validation on the user confirming ICMJE criteria', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);

  // Make sure the other answers are checked
  this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').click();
  this.$('.authors-task input[name="authors--authors_agree_to_submission"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.textPresent(
      '.authors-task .authors-task-acknowledgements .error-message:not(.error-message--hidden)',
      'Please acknowledge the statements below'
    );
    done();
  });
});

test('it requires validation on the user confirming author submission', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);

  // Make sure the other answers are checked
  this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').click();
  this.$('.authors-task input[name="authors--authors_confirm_icmje_criteria"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.textPresent(
      '.authors-task .authors-task-acknowledgements .error-message:not(.error-message--hidden)',
      'Please acknowledge the statements below'
    );
    done();
  });
});

test('it requires its authors to be valid', function(assert){
  let testTask = createTaskWithInvalidAuthor();
  this.set('testTask', testTask);
  this.render(template);

  // Make sure required questions on the task are answered
  this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').click();
  this.$('.authors-task input[name="authors--authors_confirm_icmje_criteria"]').click();
  this.$('.authors-task input[name="authors--authors_agree_to_submission"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    // we do not assert individual errors for the author here, do that in
    // its own component test
    assert.textPresent('.authors-task', 'Please fix all errors');
    done();
  });
});

test('it lets you complete the task when there are no validation errors', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);

  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
  this.render(template);

  // Answer required questions
  this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').click();
  this.$('.authors-task input[name="authors--authors_confirm_icmje_criteria"]').click();
  this.$('.authors-task input[name="authors--authors_agree_to_submission"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), true, 'task was completed');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    done();
  });
});

test('it lets you uncomplete the task when it and its authors have validation errors', function(assert) {
  let testTask = createTaskWithInvalidAuthor();
  this.set('testTask', testTask);

  Ember.run(() => {
    testTask.set('completed', true);
  });

  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
  this.render(template);

  assert.equal(testTask.get('completed'), true, 'task was initially completed');
  this.$('.authors-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task was marked as incomplete');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    $.mockjax.clear();

    // ensure  a required answer is not provided
    this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').attr('checked', false);

    // try complete again
    this.$('.authors-task button.task-completed').click();

    wait().then(() => {
      assert.mockjaxRequestNotMade('/api/tasks/1', 'PUT');
      assert.textPresent('.authors-task', 'Please fix all errors');
      assert.equal(testTask.get('completed'), false, 'task did not change completion status');
      done();
    });
  });
});
