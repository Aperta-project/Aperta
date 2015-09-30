import Ember from 'ember';
import { test, moduleForModel } from 'ember-qunit';
moduleForModel('task', 'Unit: Task Model', {
  needs: ['model:author', 'model:user', 'model:figure', 'model:table', 'model:bibitem',
    'model:journal',
    'model:decision', 'model:invitation', 'model:affiliation', 'model:attachment',
    'model:question-attachment', 'model:comment-look',
    'model:phase', 'model:task', 'model:comment', 'model:participation',
    'model:card-thumbnail', 'model:question', 'model:nested-question-owner',
    'model:nested-question', 'model:nested-question-answer', 'model:collaboration',
    'model:supporting-information-file', 'model:paper']
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

test("findQuestion can take a path that made of parts separated by a dot (.) and search deeply for the nestedQuestion", function(assert) {
  let store = this.store(),
    task, nestedQuestion, nestedChildQuestion, evenDeeperNestedChildQuestion;

  Ember.run(() => {
    task = store.createRecord('task');
    nestedQuestion = store.createRecord('nested-question', {
      ident: "foobar",
      task: task
    });
    nestedChildQuestion = store.createRecord('nested-question', { ident: 'nested-baz'});
    evenDeeperNestedChildQuestion = store.createRecord('nested-question', { ident: 'hrm'});

    task.get('nestedQuestions').addObject(nestedQuestion);
    nestedQuestion.get('children').addObject(nestedChildQuestion);
    nestedChildQuestion.get('children').addObject(evenDeeperNestedChildQuestion);

    return task;
  });

  // find foobar, then search foobar's children for nested-baz
  assert.equal(task.findQuestion('foobar.nested-baz'), nestedChildQuestion);

  // there's no top-level child matching the ident nested-baz, so find nothing
  assert.equal(task.findQuestion('nested-baz'), null);
});

test("findQuestion returns null when it doesn't find a deeply nested match when using dot (.) path syntax", function(assert) {
  let store = this.store(),
    task, nestedQuestion, nestedChildQuestion;

  Ember.run(() => {
    task = store.createRecord('task');
    nestedQuestion = store.createRecord('nested-question', {
      ident: "foobar",
      task: task
    });
    nestedChildQuestion = store.createRecord('nested-question', { ident: 'nested-baz'});

    task.get('nestedQuestions').addObject(nestedQuestion);
    nestedQuestion.get('children').addObject(nestedChildQuestion);

    return task;
  });

  assert.equal(task.findQuestion('foobar.nope-baz'), null);
  assert.equal(task.findQuestion('foobar.nope-baz.hrm'), null);
});
