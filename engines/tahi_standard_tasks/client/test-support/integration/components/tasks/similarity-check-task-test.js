import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

var template = hbs`{{similarity-check-task task=task can=can container=container}}`;

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


var newTask = function(completed, paper) {
  return {
    id: 2,
    title: 'Title and Abstract',
    type: 'TahiStandardTasks::TitleAndAbstractTask',
    completed: completed,
    isMetadataTask: false,
    isSubmissionTask: true,
    assignedToMe: true,
    paper: paper
  };
};

var paperStub = {
  title: 'Paper title',
  abstract: 'Paper abstract',
  editable: true,
  manuallySimilarityChecked: false
}

moduleForComponent(
  'similarity-check-task',
  'Integration | Components | Tasks | Similarity Check Task', {
  integration: true
});

test('proper state for a non manually generated check', function(assert) {
  let task = newTask(false, paperStub);
  setupEditableTask(this, task);
  assert.elementFound('.similarity-check-task',
                       'the similarity check renders');
  assert.elementFound('.automated-report-status',
                       'it has an automated report status by default');
  assert.elementFound('.generate-confirm',
                       'it has a generate report button');

  $('.generate-confirm').click()

  assert.elementFound('.confirm-container',
                   'it has a generate report button');
  assert.equal($('.confirm-container h4').html(),
                   'Manually generating the report will disable the automated similarity check for this manuscript',
                   'has the correct text');
});

test('proper state for a manually generated check', function(assert) {
  let paper = paperStub;
  paper.manuallySimilarityChecked = true
  var task = newTask(false, paper);
  setupEditableTask(this, task);

  assert.elementFound('.similarity-check-task',
                       'the similarity check renders');
  assert.elementNotFound('.automated-report-status',
                       'it has an automated report status by default');
  assert.elementFound('.generate-confirm',
                       'it has a generate report button');

  $('.generate-confirm').click()

  assert.elementFound('.confirm-container',
                   'it has a generate report button');
  assert.equal($('.confirm-container h4').html(),
                   `Are you sure?`,
                   'has the correct text');
});
