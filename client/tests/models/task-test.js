import Ember from 'ember';
import { module } from 'qunit';
import { test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import registerStoreHelpers from '../helpers/store-helpers';

var app = null;
module('Unit: Task Model', {
  beforeEach: function() {
    app = startApp();
  },
  afterEach: function() {
    Ember.run(app, app.destroy);
  }
});

test("findQuestion finds and returns the first nestedQuestion when the given path matches its ident exactly", function(assert) {
  let store = getStore();
  let task, nestedQuestion;
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
  let store = getStore();
  let task, nestedQuestion;
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

test("permissionState delegates permission state to paper", function(assert) {
  registerStoreHelpers();
  let store = getStore();
  let paper, task;
  Ember.run(() => {
    paper = store.createRecord('paper', {
      permissionState: 'submitted'
    });
    task = store.createRecord('task', {
      paper: paper
    });
  });
  assert.equal(task.get('permissionState'), 'submitted');
});
