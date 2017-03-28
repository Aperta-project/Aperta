import Ember from 'ember';
import Factory from 'tahi/tests/helpers/factory';
import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';
import { moduleForComponent, test } from 'ember-qunit';
import { manualSetup, make, makeList } from 'ember-data-factory-guy';
import setupMockServer from 'tahi/tests/helpers/mock-server';

moduleForComponent(
  'register-decision-task',
  'Integration | Components | Tasks | Register Decision', {
    integration: true,

    beforeEach() {
      manualSetup(this.container);
      let nestedQuestions = makeList('nested-question',
                                     { id: 1, ident: 'register_decision_questions--to-field' },
                                     { id: 2, ident: 'register_decision_questions--subject-field' },
                                     { id: 3, ident: 'register_decision_questions--selected-template' });

      let decisions = makeList('decision', 'draft', { verdict: 'accept' }, { verdict: 'minor_revision' });
      let paper = make('paper', {
        journal: {
          id: 1,
          staffEmail: 'staffpeople@plos.org'
        },
        publishingState: 'submitted',
        decisions: decisions,
        title: 'GREAT TITLE',
        creator: {
          id: 5,
          lastName: 'Jones',
          email: 'author@example.com'
        }
      });

      let task = make('register-decision-task', {
        paper: paper,
        letterTemplates: [
          {
            id: 1,
            text: 'RA Accept',
            templateDecision: 'accept',
            to: '[AUTHOR EMAIL]',
            subject: 'Your [JOURNAL NAME] Submission',
            letterHtml: `Dear Dr. [LAST NAME],Regarding [PAPER TITLE] in [JOURNAL NAME] 
            for [JOURNAL STAFF EMAIL] Sincerely Someone who Accepts` },
          {
            id: 2,
            text: 'Editor Reject',
            templateDecision: 'reject',
            to: '[AUTHOR EMAIL]',
            subject: 'Your [JOURNAL NAME] Submission',
            letterHtml: `Dear Dr. [LAST NAME],Regarding [PAPER TITLE] 
            in [JOURNAL NAME] Sincerely who Rejects` }],
        nestedQuestions: nestedQuestions
      });

      // Mock out pusher
      this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));

      Factory.createPermission('registerDecisionTask', 1, ['edit', 'view']);

      this.set('task', task);

      // mockCreate('nested-question-answer'); does not work, so we cannot use factory guy here.
      // TODO: revisit when factory guy update
      $.mockjax({url: '/api/nested_questions/3/answers', type: 'PUT', status: 204, responseText: '[]'});
      $.mockjax({url: '/api/nested_questions/3/answers', type: 'POST', status: 204, responseText: '[]'});
      $.mockjax({url: /\/api\/decisions\/[0-9]+/, type: 'PUT', status: 204, responseText: '[]'});

      this.selectDecision = function(decision) {
        this.$(`label:contains('${decision}') input[type='radio']`).first().click();
      };

      this.select2 = function(choice) {
        Ember.run(()=>{
          let input = this.$('.select2-container input');
          input.trigger('keydown');
          input.val(choice);
          input.trigger('keyup');
          $('.select2-result-selectable').trigger('mouseup');
        });
      };

      this.render(hbs`{{register-decision-task task=task container=container}}`);
    }
  }
);

test('it renders decision selections', function(assert) {
  assert.elementsFound('.decision-label', 4);
  this.selectDecision('Accept');
  this.select2('RA Accept');
  return wait().then(()=>{
    assert.inputContains('.decision-letter-field', 'Dear');
  });
});

test('it does not update the letter contents on change of verdict unless template selection made', function(assert) {
  this.selectDecision('Accept');
  this.select2('RA Accept');
  return wait().then(()=>{
    assert.inputContains('.decision-letter-field', 'who Accepts');
    this.selectDecision('Reject');
    return wait().then(()=>{
      assert.inputContains('.decision-letter-field', 'who Accepts');
    });
  });
});

test('it switches the letter contents on change', function(assert) {
  this.selectDecision('Accept');
  this.select2('RA Accept');
  return wait().then(()=>{
    assert.inputContains('.decision-letter-field', 'who Accepts');
    this.selectDecision('Reject');
    return wait().then(()=>{
      this.select2('Editor Reject');
      return wait().then(()=>{
        assert.inputContains('.decision-letter-field', 'who Rejects');
      });
    });
  });
});

test('it replaces [LAST NAME] with the authors last name', function(assert) {
  this.selectDecision('Accept');
  this.select2('RA Accept');
  return wait().then(()=>{
    assert.inputContains('.decision-letter-field', 'Dear Dr. Jones');
  });
});

test('it replaces [JOURNAL STAFF EMAIL] with the journal staff email', function(assert) {
  this.selectDecision('Accept');
  this.select2('RA Accept');
  return wait().then(()=>{
    assert.inputContains('.decision-letter-field', 'staffpeople@plos.org');
  });
});

test('it replaces [JOURNAL NAME] with the journal name', function(assert) {
  this.selectDecision('Accept');
  this.select2('RA Accept');
  return wait().then(()=>{
    const journalName = this.task.get('paper.journal.name');
    assert.inputContains('.decision-letter-field', journalName);
  });
});

test('it replaces [PAPER TITLE] with the paper title', function(assert) {
  this.selectDecision('Accept');
  this.select2('RA Accept');
  return wait().then(()=>{
    assert.inputContains('.decision-letter-field', 'GREAT TITLE');
  });
});

test('it replaces [AUTHOR EMAIL] with the author email', function(assert) {
  this.selectDecision('Accept');
  this.select2('RA Accept');
  return wait().then(()=>{
    assert.inputContains('.to-field', 'author@example.com');
  });
});

['unsubmitted', 'in_revision', 'invited_for_full_submission', 'accepted', 'rejected'].forEach((state)=>{
  test(`when the paper is ${state}, do not show register stuff`, function(assert) {
    this.set('task', make('register-decision-task', {
      'paper': { 'publishingState': state }
    }));
    assert.textPresent('.task-main-content', 'A decision cannot be registered at this time');
  });
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
