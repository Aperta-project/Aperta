import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make, mockUpdate } from 'ember-data-factory-guy';
import Factory from 'tahi/tests/helpers/factory';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import wait from 'ember-test-helpers/wait';



let createTaskWithFiles = function(files) {
  return make('supporting-information-task', {
    paper: {
      supportingInformationFiles: files
    }
  });
}

moduleForComponent(
  'supporting-information-task',
  'Integration | Components | Tasks | Supporting Information', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    $.mockjax.clear();

    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    this.registry.register('service:can', FakeCanService);
  }
});

let template = hbs`{{supporting-information-task task=testTask}}`;
let errorSelector = '.supporting-information-thumbnail .error-message:not(.error-message--hidden)'
test('it renders the paper\'s SI files', function(assert) {

  let doneFile = make('supporting-information-file', { status: 'done' });
  let testTask = createTaskWithFiles([doneFile]);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', testTask);

  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound('.si-file', 1);
});

test("it allows completion when all the files' statuses are 'done'", function(assert) {
  let file = make('supporting-information-file', { status: 'done' });
  let testTask = createTaskWithFiles([file]);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', testTask);

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

test("it does not allow completion when any of the files' statuses are not set to 'done'", function(assert) {
  let doneFile = make('supporting-information-file', { status: 'done' });
  let processingFile = make('supporting-information-file', { status: 'processing' });
  let testTask = createTaskWithFiles([doneFile, processingFile]);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', testTask);

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

test("it does not allow completion when any of the files' statuses when category is not defined", function(assert) {
  let doneFile = make('supporting-information-file', { status: 'done', category: null });
  let testTask = createTaskWithFiles([doneFile]);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', testTask);

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

test("it does not allow completion when any of the files' statuses when label is not defined", function(assert) {
  let doneFile = make('supporting-information-file', { status: 'done', label: null });
  let testTask = createTaskWithFiles([doneFile]);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', testTask);

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
