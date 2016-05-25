import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
// Pretend like you're in client/tests even if you're in an engine.
import FakeCanService from '../helpers/fake-can-service';


moduleForComponent(
  'front-matter-reviewer-report-task',
  'Integration | Component | Tasks | front_matter_reviewer_report_task', {
  integration: true
});


test('A very important failing test', function(assert){
  var task = newTask();
  setupEditableTask(this, task);
  assert(false);
});


var newTask = function (){
  return {
    id: 2,
    title: 'front-matter-reviewer-report-task',
    type: 'front-matter-reviewer-report-task',
    completed: false,
    isMetadataTask: false,
    isSubmissionTask: false,
    assignedToMe: false
  };
};

var template = hbs`{{front-matter-reviewer-report-task task=task can=can}}`;

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
