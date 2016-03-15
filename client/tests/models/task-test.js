import Ember from 'ember';
import { test, moduleForModel } from 'ember-qunit';
moduleForModel('task', 'Unit: Task Model', {
  needs: ['model:author', 'model:user', 'model:figure', 'model:table', 'model:bibitem',
    'model:journal', 'model:discussion-topic', 'model:versioned-text',
    'model:decision', 'model:invitation', 'model:affiliation', 'model:attachment',
    'model:question-attachment', 'model:comment-look',
    'model:phase', 'model:task', 'model:comment', 'model:participation',
    'model:card-thumbnail', 'model:nested-question-owner',
    'model:nested-question', 'model:nested-question-answer', 'model:collaboration',
    'model:supporting-information-file', 'model:paper', 'model:snapshot',
    'model:paper-task-type']
});

test("findQuestion finds and returns the first nestedQuestion when the given path matches its ident exactly", function(assert) {
  let store = this.store(),
    task, nestedQuestion;

  Ember.run(() => {
    task = store.createRecord('task');
    nestedQuestion = store.createRecord('nested-question', {
      ident: "foobar",
      task: task
    });
    task.get('nestedQuestions').addObject(nestedQuestion);
    return task;
  });

  assert.equal(task.findQuestion('foobar'), nestedQuestion);
});

test("findQuestion returns null when it doesn't have a nestedQuestion whose ident that matches the given path", function(assert) {
  let store = this.store(),
    task, nestedQuestion;

  Ember.run(() => {
    task = store.createRecord('task');
    nestedQuestion = store.createRecord('nested-question', {
      ident: "foobar",
      task: task
    });
    task.get('nestedQuestions').addObject(nestedQuestion);
    return task;
  });

  assert.equal(task.findQuestion('bazbaz'), null);
});
