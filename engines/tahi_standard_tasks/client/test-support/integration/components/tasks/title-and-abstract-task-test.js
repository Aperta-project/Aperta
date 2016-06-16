import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
// Pretend like you're in client/tests
import FakeCanService from '../../../helpers/fake-can-service';


moduleForComponent(
  'title-and-abstract-task',
  'Integration | Components | Tasks | Title and Abstract', {
  integration: true
});

test('User can edit the title and abstract', function(assert) {
  var task = newTask(false, true);
  setupEditableTask(this, task);
  assert.elementsFound('.form-textarea.ember-view.format-input',
                       2,
                       'User can edit the title and abstract');
});

test('Title and abstract are not editable when the paper is not', function(assert) {
  var task = newTask(false, false);
  setupEditableTask(this, task);
  assert.elementsFound('.form-textarea.ember-view.format-input.read-only',
                       2,
                       'User can edit the title and abstract');
});

test('Title and abstract are not editable when the task is complete', function(assert) {
  var task = newTask(true, true);
  setupEditableTask(this, task);
  assert.elementsFound('.form-textarea.ember-view.format-input.read-only',
                       2,
                       'User can edit the title and abstract');
});

test('Title and abstract are not editable when the task is complete and paper is not editable', function(assert) {
  var task = newTask(true, false);
  setupEditableTask(this, task);
  assert.elementsFound('.form-textarea.ember-view.format-input.read-only',
                       2,
                       'User can edit the title and abstract');
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

