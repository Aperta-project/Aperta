import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
// Pretend like you're in client/tests
import FakeCanService from '../../../helpers/fake-can-service';

var template = hbs`{{similarity-check-task task=task }}`;
// var template = hbs`{{similarity-check-task task=task can=can container=container}}`;

var setupEditableTask = function(context, task) {
  task = task || newTask();
  // var can = FakeCanService.create();
  // can.allowPermission('edit', task);

  context.setProperties({
    // can: can,
    task: task
  });

  context.render(template);
};


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

moduleForComponent(
  'similarity-check-task',
  'Integration | Components | Tasks | Title and Abstract', {
  integration: true,
  beforeEach() {}
});

test('proper state for a non manually generated check', function(assert) {
  var task = newTask(false, true);
  setupEditableTask(this, task);

  assert.elementFound('.similarity-check-task',
                       'the similarity check renders');

  assert.elementFound('.automated-report-status',
                       'it has an automated report status by default');

  assert.elementFound('.generate-confirm',
                       'it has a generate report button');

  click('.generate-confirm')
  andThen(function() {
      assert.elementFound('.confirm-container',
                       'it has a generate report button');

      assert.textFound(this isnt real replace)('Manually generating the report will disable the automated similarity check for this manuscript')
  })
});

test('proper state for a manually generated check', function(assert) {
  var task = newTask(false, true);
  setupEditableTask(this, task);

  assert.elementFound('.similarity-check-task',
                       'the similarity check renders');

  assert.elementNotFound('.automated-report-status',
                       'it has an automated report status by default');

  assert.elementFound('.generate-confirm',
                       'it has a generate report button');

  click('.generate-confirm')
  andThen(function() {
    assert.textFound(this isnt real replace)('Generate Report')
  })
});
