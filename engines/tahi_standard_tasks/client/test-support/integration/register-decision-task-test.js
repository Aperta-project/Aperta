import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import FakeCanService from '../helpers/fake-can-service';
import FactoryGuy from 'ember-data-factory-guy';
import FactoryGuyPaper from '../factories/paper';
import FactoryGuyDecision from '../factories/decision';
import FactoryGuyTask from '../factories/task';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';


moduleForComponent(
  'register-decision-task',
  'Integration | Components | Tasks | Register Decision', {
  integration: true,

  beforeEach: function(){
    initTruthHelpers();
    FactoryGuy.setStore(this.container.lookup("store:main"));
  }
});


test('User has the ability to rescind', function(assert){
  let acceptedDecision = FactoryGuy.make('decision', {
    verdict: 'accept',
    rescindable: true });
  let paper = FactoryGuy.make('paper', {
    decisions: [acceptedDecision] });
  var task = FactoryGuy.make('task', { paper: paper });

  setupEditableTask(this, task);

  assert.elementFound(
    '.rescind-decision',
    'User sees the rescind decision bar'
  );
});

test('User can see the decision history', function(assert){
  let decisions = [
    FactoryGuy.make('decision', {verdict: null, registered: false}),
    FactoryGuy.make('decision', {verdict: 'accept', registered: true}),
    FactoryGuy.make('decision', {verdict: 'minor_revision', registered: true})
  ];
  let paper = FactoryGuy.make('paper', { decisions: decisions });
  var task = FactoryGuy.make('task', { paper: paper });

  setupEditableTask(this, task);

  assert.nElementsFound(
    '.decision-bar',
    2,
    'User sees only completed decisions'
  );
});


var newTask = function() {
  return {
    id: 2,
    title: 'Register Decision',
    type: 'TahiStandardTasks::RegisterDecisionTask',
    completed: false,
    isMetadataTask: false,
    isSubmissionTask: false,
    assignedToMe: false,
    paper: {
      decisions: []
    }
  };
};

var template = hbs`{{register-decision-task task=task can=can container=container}}`;

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
