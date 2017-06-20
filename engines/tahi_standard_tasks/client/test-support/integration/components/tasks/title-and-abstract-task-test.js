import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

// Pretend like you're in client/tests
import FakeCanService from '../../../helpers/fake-can-service';
import {findEditor} from 'tahi/tests/helpers/rich-text-editor-helpers';

moduleForComponent(
  'title-and-abstract-task',
  'Integration | Components | Tasks | Title and Abstract', {
    integration: true
  });

test('User can edit the title and abstract', function(assert) {
  var task = newTask(false, true);
  setupEditableTask(this, task);
  let title = findEditor('article-title-input');
  let abstract = findEditor('article-abstract-input');
  assert.ok(title);
  assert.ok(abstract);
});

test('Title/abstract not editable when paper is not', function(assert) {
  var task = newTask(false, false);
  setupEditableTask(this, task);
  let title = findEditor('article-title-input');
  let abstract = findEditor('article-abstract-input');
  assert.ok(!title);
  assert.ok(!abstract);
});

test('Title/abstract not editable when task is complete', function(assert) {
  var task = newTask(true, true);
  setupEditableTask(this, task);
  let title = findEditor('article-title-input');
  let abstract = findEditor('article-abstract-input');
  assert.ok(!title);
  assert.ok(!abstract);
});

test('Title/abstract not editable when task is complete and paper not editable', function(assert) {
  var task = newTask(true, false);
  setupEditableTask(this, task);
  let title = findEditor('article-title-input');
  let abstract = findEditor('article-abstract-input');
  assert.ok(!title);
  assert.ok(!abstract);
});

var newTask = function(completed, paperEditable) {
  return {
    id: 2,
    title: 'Title and Abstract',
    type: 'TahiStandardTasks::TitleAndAbstractTask',
    completed: completed,
    isMetadataTask: false,
    isSubmissionTask: false,
    assignedToMe: false,
    paper: {
      title: 'Paper title',
      abstract: 'Paper abstract',
      editable: paperEditable
    }
  };
};

var template = hbs`{{title-and-abstract-task task=task can=can container=container}}`;

var setupEditableTask = function(context, task) {
  task = task || newTask();
  var can = FakeCanService.create();
  can.allowPermission('edit', task);

  context.setProperties({
    can: can,
    task: task
  });

  context.render(template);
};

