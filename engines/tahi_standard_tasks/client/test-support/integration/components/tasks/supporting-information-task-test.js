import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make, mockUpdate } from 'ember-data-factory-guy';
import Factory from 'tahi/tests/helpers/factory';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import wait from 'ember-test-helpers/wait';

let emberContainer;

let createTaskWithFiles = function(files) {
  return make('supporting-information-task', {
    paper: {
      id: 1,
      supportingInformationFiles: files
    }
  });
};

let allowPermissionOnTask = function(permission, task){
  let fakeCanService = emberContainer.lookup('service:can');
  fakeCanService.allowPermission('edit', task);
};

moduleForComponent(
  'supporting-information-task',
  'Integration | Components | Tasks | Supporting Information', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    $.mockjax.clear();

    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    this.registry.register('service:can', FakeCanService);

    emberContainer = this.container;
  },
  afterEach() {
    $.mockjax.clear();
  }
});

let template = hbs`{{supporting-information-task task=testTask}}`;
let errorSelector = '.supporting-information-thumbnail .error-message:not(.error-message--hidden)';

test("it renders the paper's SI files", function(assert) {
  let doneFile = make('supporting-information-file', { status: 'done' });
  let testTask = createTaskWithFiles([doneFile]);
  allowPermissionOnTask('edit', testTask);
  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound('.si-file', 1);
});

test("it renders the paper's supportingInformationFiles", function(assert) {
  let testTask = createTaskWithFiles([
    make('supporting-information-file', {title: 'SI File. 1', id: 1})
  ]);
  this.set('testTask', testTask);
  this.render(template);

  let done = assert.async();
  wait().then(() => {
    assert.elementsFound('.si-file', 1);
    done();
  });
});

test('it reports validation errors on the task when attempting to complete', function(assert) {
  let testTask = createTaskWithFiles([
    make('supporting-information-file', {label: null, id: 1})
  ]);
  allowPermissionOnTask('edit', testTask);
  this.set('testTask', testTask);

  this.render(template);
  assert.elementsFound('.si-file', 1);
  this.$('.supporting-information-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    // Error at the task level
    assert.textPresent('.supporting-information-task', 'Please fix all errors');
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
    done();
  });
});

test('it requires validation on an SI file label', function(assert) {
  let testTask = createTaskWithFiles([
    make('supporting-information-file', {label: null, id: 1, status: 'done'})
  ]);
  allowPermissionOnTask('edit', testTask);
  this.set('testTask', testTask);
  this.render(template);
  this.$('.supporting-information-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.elementFound('.si-file .error-message:not(.error-message--hidden)');
    assert.textPresent('.si-file .error-message', 'Please edit');
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
    done();
  });
});

test('it requires validation on an SI file category', function(assert) {
  let testTask = createTaskWithFiles([
    make('supporting-information-file', {category: null, status: 'done', id: 1})
  ]);
  allowPermissionOnTask('edit', testTask);
  this.set('testTask', testTask);
  this.render(template);
  this.$('.supporting-information-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.elementFound('.si-file .error-message:not(.error-message--hidden)');
    assert.textPresent('.si-file .error-message', 'Please edit');
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
    done();
  });
});

test("it allows completion when all the files have a status of 'done'", function(assert) {
  let file = make('supporting-information-file', { status: 'done' });
  let testTask = createTaskWithFiles([file]);
  allowPermissionOnTask('edit', testTask);
  this.set('testTask', testTask);
  let testUrl = `/api/tasks/${testTask.id}`;
  $.mockjax({url: testUrl, type: 'PUT', status: 204, responseText: '{}'});

  this.render(template);

  this.$('.task-completed').click();
  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), true, 'task is completed');
    assert.mockjaxRequestMade(testUrl, 'PUT', 'it saves the task')
    done();
  });
});

test('it does not allow the user to complete when there are validation errors', function(assert) {
  let testTask = createTaskWithFiles([
    make('supporting-information-file', {label: null, id: 1})
  ]);
  allowPermissionOnTask('edit', testTask);
  this.set('testTask', testTask);
  this.render(template);
  this.$('.supporting-information-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
    done();
  });
});

test("it does not allow completion when any of the files' statuses are not set to 'done'", function(assert) {
  let doneFile = make('supporting-information-file', { status: 'done' });
  let processingFile = make('supporting-information-file', { status: 'processing' });
  let testTask = createTaskWithFiles([doneFile, processingFile]);
  allowPermissionOnTask('edit', testTask);

  this.set('testTask', testTask);
  let testUrl = `/api/tasks/${testTask.id}`;
  $.mockjax({url: testUrl, type: 'PUT', status: 204, responseText: '{}'});

  this.render(template);

  this.$('.task-completed').click();
  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task remains uncompleted');
    assert.mockjaxRequestNotMade('/api/tasks/1', 'PUT', 'it does not save the task')
    done();
  });
});

test("it does not allow completion when any of the files' labels are not defined", function(assert) {
  let doneFile = make('supporting-information-file', { status: 'done', label: null });
  let testTask = createTaskWithFiles([doneFile]);
  allowPermissionOnTask('edit', testTask);
  this.set('testTask', testTask);
  let testUrl = `/api/tasks/${testTask.id}`;
  $.mockjax({url: testUrl, type: 'PUT', status: 204, responseText: '{}'});

  this.render(template);

  this.$('.task-completed').click();
  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task remains uncompleted');
    assert.mockjaxRequestNotMade('/api/tasks/1', 'PUT', 'it does not save the task')
    done();
  });
});

test("it does not allow completion when any of the files' categories is not defined", function(assert) {
  let doneFile = make('supporting-information-file', { status: 'done', category: null });
  let testTask = createTaskWithFiles([doneFile]);
  allowPermissionOnTask('edit', testTask);

  this.set('testTask', testTask);
  let testUrl = `/api/tasks/${testTask.id}`;
  $.mockjax({url: testUrl, type: 'PUT', status: 204, responseText: '{}'});

  this.render(template);

  this.$('.task-completed').click();
  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task remains uncompleted');
    assert.mockjaxRequestNotMade('/api/tasks/1', 'PUT', 'it does not save the task')
    done();
  });
});

test('it lets you uncomplete the task when it has validation errors', function(assert) {
  let testTask = createTaskWithFiles([
    make('supporting-information-file', {category: null, id: 1})
  ]);
  this.set('testTask', testTask);
  allowPermissionOnTask('edit', testTask);

  Ember.run(() => {
    testTask.set('completed', true);
  });

  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
  this.render(template);

  assert.equal(testTask.get('completed'), true, 'task was initially completed');
  this.$('.supporting-information-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task was marked as incomplete');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    $.mockjax.clear();

    // make sure we cannot mark it as complete, to ensure it truly was invalid
    this.$('.supporting-information-task button.task-completed').click();
    wait().then(() => {
      assert.mockjaxRequestNotMade('/api/tasks/1', 'PUT');
      assert.textPresent('.supporting-information-task', 'Please fix all errors');
      assert.equal(testTask.get('completed'), false, 'task did not change completion status');
      done();
    });
  });
});
