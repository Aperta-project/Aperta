import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import wait from 'ember-test-helpers/wait';
import registerCustomAssertions from '../../../helpers/custom-assertions';
import Factory from '../../../helpers/factory';

let createTask = function() {
  return make('register-decision-task', {
    paper: {
      journal: {
        id: 1
      },
      publishingState: 'submitted',
      decisions: [
        { id: 1 }
      ],
      shortTitle: 'GREAT TITLE'
    },
    letterTemplates: [
      { 
        id: 1,
        text: 'RA Accept',
        templateDecision: 'accept',
        subject: 'Your [JOURNAL NAME] Submission',
        letter: 'Dear Dr. [LAST NAME],Regarding [PAPER TITLE] in [JOURNAL NAME] Sincerely Someone who Accepts' },
      {
        id: 2,
        text: 'Editor Reject',
        templateDecision: 'reject',
        subject: 'Your [JOURNAL NAME] Submission',
        letter: 'Dear Dr. [LAST NAME],Regarding [PAPER TITLE] in [JOURNAL NAME] Sincerely who Rejects' }],
    nestedQuestions: [
      { id: 1, ident: 'register_decision_questions--to-field' },
      { id: 2, ident: 'register_decision_questions--subject-field' }]
  });
};

let fakeUser = Factory.createRecord('User', {
  id: 1,
  fullName: 'Fake User',
  lastName: 'Smith',
  username: 'fakeuser',
  email: 'fakeuser@example.com'
});

moduleForComponent(
  'register-decision-task',
  'Integration | Components | Tasks | Register Decision', {
  integration: true,


  beforeEach() {
    // Mock out pusher
    this.container.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    manualSetup(this.container);
    Factory.createPermission('registerDecisionTask', 1, ['edit', 'view']);
  }
});

let template = hbs`{{register-decision-task task=testTask currentUser=fakeUser}}`;

test('it renders decision selections', function(assert) {
  let testTask = createTask();
  this.set('fakeUser', fakeUser);
  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound('.decision-label', 4);
  this.$("input[type='radio']").last().click();
  assert.inputContains('.decision-letter-field', 'Dear');
});

test('it switches the letter contents on change', function(assert) {
  let testTask = createTask();
  this.set('fakeUser', fakeUser);
  this.set('testTask', testTask);
  this.render(template);
  this.$("input[type='radio']").last().click();
  assert.inputContains('.decision-letter-field', 'who Accepts');
  this.$("input[type='radio']").first().click();
  assert.inputContains('.decision-letter-field', 'who Rejects');
});

test('it replaces [LAST NAME] with the authors last name', function(assert) {
  let testTask = createTask();
  this.set('fakeUser', fakeUser);
  this.set('testTask', testTask);
  this.render(template);
  this.$("input[type='radio']").last().click();
  assert.inputContains('.decision-letter-field', 'Dear Dr. Smith');
});

test('it replaces [JOURNAL NAME] with the journal name', function(assert) {
  let testTask = createTask();
  this.set('fakeUser', fakeUser);
  this.set('testTask', testTask);
  this.render(template);
  this.$("input[type='radio']").last().click();
  let journalName = testTask.get('paper.journal.name');
  assert.inputContains('.decision-letter-field', journalName);
});

test('it replaces [PAPER TITLE] with the paper title', function(assert) {
  let testTask = createTask();
  this.set('fakeUser', fakeUser);
  this.set('testTask', testTask);
  this.render(template);
  this.$("input[type='radio']").last().click();
  assert.inputContains('.decision-letter-field', 'GREAT TITLE');
});

