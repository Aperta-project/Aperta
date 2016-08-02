import Ember from 'ember';
import Factory from '../../../helpers/factory';
import hbs from 'htmlbars-inline-precompile';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import { manualSetup, make, mockReload } from 'ember-data-factory-guy';
import { moduleForComponent, test } from 'ember-qunit';

let createTask = function() {
  return make('register-decision-task', {
    paper: {
      journal: {
        id: 1
      },
      publishingState: 'submitted',
      decisions: [
        {
          id: 1,
          latest: true
        },
        { id: 2,
          verdict: 'accept', registeredAt: new Date()},
        { id: 3,
          verdict: 'minor_revision', registeredAt: new Date()}
      ],
      shortTitle: 'GREAT TITLE',
      creator: {
        id: 5,
        lastName: 'Jones',
        email: 'author@example.com'
      }
    },
    letterTemplates: [
      {
        id: 1,
        text: 'RA Accept',
        templateDecision: 'accept',
        to: '[AUTHOR EMAIL]',
        subject: 'Your [JOURNAL NAME] Submission',
        letter: 'Dear Dr. [LAST NAME],Regarding [PAPER TITLE] in [JOURNAL NAME] Sincerely Someone who Accepts' },
      {
        id: 2,
        text: 'Editor Reject',
        templateDecision: 'reject',
        to: '[AUTHOR EMAIL]',
        subject: 'Your [JOURNAL NAME] Submission',
        letter: 'Dear Dr. [LAST NAME],Regarding [PAPER TITLE] in [JOURNAL NAME] Sincerely who Rejects' }],
    nestedQuestions: [
      { id: 1, ident: 'register_decision_questions--to-field' },
      { id: 2, ident: 'register_decision_questions--subject-field' }]
  });
};

moduleForComponent(
  'register-decision-task',
  'Integration | Components | Tasks | Register Decision', {
    integration: true,

    beforeEach() {
      // Mock out pusher
      this.container.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
      manualSetup(this.container);
      // FactoryGuy.setStore(this.container.lookup("store:main"));
      Factory.createPermission('registerDecisionTask', 1, ['edit', 'view']);
      initTruthHelpers();
      const task = createTask();

      this.setProperties({
        task: task
      });

      this.task.get('decisions').forEach(function (decision) {
        mockReload('decision', decision.get('id'));
      });
      this.render(template);
      this.selectDecision = function(decision) {
        this.$(`label:contains('${decision}') input[type='radio']`).first().click();
      };
    }
  }
);

const template = hbs`{{register-decision-task task=task container=container}}`;

test('it renders decision selections', function(assert) {
  assert.elementsFound('.decision-label', 4);
  this.selectDecision('Accept');
  assert.inputContains('.decision-letter-field', 'Dear');
});

test('it switches the letter contents on change', function(assert) {
  this.selectDecision('Accept');
  assert.inputContains('.decision-letter-field', 'who Accepts');
  this.selectDecision('Reject');
  assert.inputContains('.decision-letter-field', 'who Rejects');
});

test('it replaces [LAST NAME] with the authors last name', function(assert) {
  this.selectDecision('Accept');
  assert.inputContains('.decision-letter-field', 'Dear Dr. Jones');
});

test('it replaces [JOURNAL NAME] with the journal name', function(assert) {
  this.selectDecision('Accept');
  let journalName = this.task.get('paper.journal.name');
  assert.inputContains('.decision-letter-field', journalName);
});

test('it replaces [PAPER TITLE] with the paper title', function(assert) {
  this.selectDecision('Accept');
  assert.inputContains('.decision-letter-field', 'GREAT TITLE');
});

test('it replaces [AUTHOR EMAIL] with the author email', function(assert) {
  this.selectDecision('Accept');
  assert.inputContains('.to-field', 'author@example.com');
});

test('User has the ability to rescind', function(assert){
  assert.elementFound(
    '.rescind-decision',
    'User sees the rescind decision bar'
  );
});

test('User can see the decision history', function(assert){
  assert.nElementsFound(
    '.decision-bar',
    2,
    'User sees only completed decisions'
  );
});
