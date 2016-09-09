import Ember from 'ember';
import { test, moduleForModel } from 'ember-qunit';
moduleForModel('nested-question-answer', 'Unit: NestedQuestionAnswer Model', {
  needs: ['model:author', 'model:user', 'model:figure', 'model:bibitem',
    'model:journal',
    'model:decision', 'model:invitation', 'model:affiliation', 'model:attachment',
    'model:question-attachment', 'model:comment-look',
    'model:phase', 'model:task', 'model:comment', 'model:participation',
    'model:card-thumbnail', 'model:nested-question-owner',
    'model:nested-question', 'model:nested-question-answer', 'model:collaboration',
    'model:supporting-information-file', 'model:paper']
});

test("wasAnswered returns true when the answer has a value (including false)", function(assert) {
  let store = this.store(),
    nestedQuestionAnswer;

  Ember.run(() => {
    nestedQuestionAnswer = store.createRecord('nested-question-answer');
    nestedQuestionAnswer.set('value', true);
  });
  assert.equal(nestedQuestionAnswer.get('wasAnswered'), true);

  Ember.run(() => { nestedQuestionAnswer.set('value', false); });
  assert.equal(nestedQuestionAnswer.get('wasAnswered'), true);

  Ember.run(() => { nestedQuestionAnswer.set('value', 'some value'); });
  assert.equal(nestedQuestionAnswer.get('wasAnswered'), true);
});

test("wasAnswered returns false when the answer doesn't have a value", function(assert) {
  let store = this.store(),
    nestedQuestionAnswer;

  Ember.run(() => {
    nestedQuestionAnswer = store.createRecord('nested-question-answer');
    nestedQuestionAnswer.set('value', null);
  });
  assert.equal(nestedQuestionAnswer.get('wasAnswered'), false);

  Ember.run(() => { nestedQuestionAnswer.set('value', undefined); });
  assert.equal(nestedQuestionAnswer.get('wasAnswered'), false);

  Ember.run(() => { nestedQuestionAnswer.set('value', ''); });
  assert.equal(nestedQuestionAnswer.get('wasAnswered'), false);

  Ember.run(() => { nestedQuestionAnswer.set('value', []); });
  assert.equal(nestedQuestionAnswer.get('wasAnswered'), false);
});
