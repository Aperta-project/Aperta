import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make, mockUpdate } from 'ember-data-factory-guy';
import Factory from 'tahi/tests/helpers/factory';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import wait from 'ember-test-helpers/wait';



let createTaskWithFiles = function(files) {
  return make('supporting-information-task', {
    id: 1,
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
  }
});

let template = hbs`{{supporting-information-task task=testTask}}`;
let errorSelector = '.supporting-information-thumbnail .error-message:not(.error-message--hidden)'
test('it renders the paper\'s SI files', function(assert) {
  this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
  this.registry.register('service:can', FakeCanService);

  let testTask = createTaskWithFiles([{title: 'Supporting Info. 1', id: 1, status: 'done'}]);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', testTask);

  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound('.si-file', 1);
});

test("it allows completion when all the files' statuses are 'done'", function(assert) {
  this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
  this.registry.register('service:can', FakeCanService);
  let file = {title: 'Supporting Info. 1', id: 1, status: 'done', label: "test label", category: "test category"}
  let testTask = createTaskWithFiles([file]);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', testTask);

  this.set('testTask', testTask);
  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});

  this.render(template);

  this.$('.task-completed').click();
  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT', 'it saves the task')
    done();
  });
});