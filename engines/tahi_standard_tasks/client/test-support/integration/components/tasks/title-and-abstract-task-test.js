import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
// Pretend like you're in client/tests even if you're in an engine.
import FakeCanService from '../helpers/fake-can-service';


moduleForComponent(
  'title-and-abstract-task',
  'Integration | Component | Tasks | title_and_abstract_task', {
  integration: true
});


test('A very important failing test', function(assert){
  var task = newTask();
  setupEditableTask(this, task);
  assert(false);
});

test('Task is not editable when completed', function(assert){
  var task = newTask();
  setupEditableTask(this, task);
  task.completed = true;
  assert(task.isNotEditable);
}

test('Task is not editable when paper is not editable', function(assert){
  var task = newTask();
  setupEditableTask(this, task);
  task.paper.editable = false;
  assert(task.isNotEditable);
}

test('Task is not editable when paper is not editable and task is completed', function(assert){
  var task = newTask();
  setupEditableTask(this, task);
  task.completed = true;
  task.paper.editable = false;
  assert(task.isNotEditable);
}

test('task is editable when it is supposed to be', function(assert){
  var task = newTask();
  setupEditableTask(this, task);
  assert(task.isNotEditable == false);
}

var newTask = function (){
  return {
    id: 2,
    title: 'title-and-abstract',
    type: 'title-and-abstract-task',
    completed: false,
    isMetadataTask: false,
    isSubmissionTask: false,
    assignedToMe: false
  };
};

var template = hbs`{{title-and-abstract-task task=task can=can}}`;

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
