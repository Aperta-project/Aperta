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
      ]
    },
    letterTemplates: [
      { 
        id: 1,
        text: 'RA Accept',
        templateDecision: 'accept',
        letter: 'Dear Dr. [LAST_NAME], Sincerely Someone who Accepts' },
      {
        id: 2,
        text: 'Editor Reject',
        templateDecision: 'reject',
        letter: 'Dear Dr. [LAST_NAME], Sincerely who Rejects' }],
    nestedQuestions: [
      { id: 1, ident: 'register_decision_questions--to-field' }]
  });
};

moduleForComponent(
  'register-decision-task',
  'Integration | Components | Tasks | Register Decision', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    Factory.createPermission('registerDecisionTask', 1, ['edit', 'view']);
  }
});

let template = hbs`{{register-decision-task task=testTask}}`;

test('it renders decision selections', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound('.decision-label', 4);
  this.$("input[type='radio']").last().click();
  assert.inputContains('.decision-letter-field', 'Dear');
});

test('it switches the letter contents on change', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);
  this.$("input[type='radio']").last().click();
  assert.inputContains('.decision-letter-field', 'who Accepts');
  this.$("input[type='radio']").first().click();
  assert.inputContains('.decision-letter-field', 'who Rejects');
});

test('it replaces template variables', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);
  this.$("input[type='radio']").last().click();
  assert.inputContains('.decision-letter-field', 'Dear Dr. Smith');
});
