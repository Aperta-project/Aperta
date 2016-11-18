// Generated by CoffeeScript 1.10.0
import Ember from 'ember';
import startApp from '../helpers/start-app';
import { test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { make, makeList } from 'ember-data-factory-guy';
import Factory from '../helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
var App;

App = null;

module('Integration: Commenting', {
  afterEach: function() {
    Ember.run(function() {
      return TestHelper.teardown();
    });
    return Ember.run(App, App.destroy);
  },
  beforeEach: function() {
    App = startApp();
    TestHelper.setup(App);
    $.mockjax({
      url: '/api/admin/journals/authorization',
      status: 204
    });
    $.mockjax({
      url: '/api/journals',
      status: 200,
      responseText: {
        journals: []
      }
    });
    return TestHelper.mockFindAll('discussion-topic', 1);
  }
});

test('A card with more than 5 comments has the show all comments button', function(assert) {
  var comments, paper, task;
  assert.expect(3);
  paper = make('paper');
  comments = makeList('comment', 10);
  task = make('ad-hoc-task', {
    paper: paper,
    comments: comments,
    body: []
  });
  Factory.createPermission('Paper', paper.id, ['view']);
  Factory.createPermission('AdHocTask', task.id, ['view', 'edit']);
  TestHelper.mockFind('paper').returns({
    model: paper
  });
  TestHelper.mockFind('task').returns({
    model: task
  });
  visit('/papers/' + (paper.get('id')) + '/tasks/' + (task.get('id')));
  return andThen(function() {
    assert.ok(find('.load-all-comments').length === 1);
    assert.equal(find('.message-comment').length, 5, 'Only 5 messages displayed');
    click('.load-all-comments');
    return andThen(function() {
      return assert.equal(find('.message-comment').length, 10, 'All messages displayed');
    });
  });
});

test('A card with less than 5 comments doesnt have the show all comments button', function(assert) {
  var comments, paper, task;
  assert.expect(3);
  paper = FactoryGuy.make('paper');
  comments = makeList('comment', 3);
  task = FactoryGuy.make('ad-hoc-task', {
    paper: paper,
    body: [],
    comments: comments
  });
  Factory.createPermission('Paper', paper.id, ['view']);
  Factory.createPermission('AdHocTask', task.id, ['view', 'edit']);
  TestHelper.mockFind('paper').returns({
    model: paper
  });
  TestHelper.mockFind('task').returns({
    model: task
  });
  visit('/papers/' + (paper.get('id')) + '/tasks/' + (task.get('id')));
  return andThen(function() {
    assert.ok(find('.load-all-comments').length === 0);
    assert.equal(find('.message-comment').length, 3, 'All messages displayed');
    return assert.equal(find('.message-comment.unread').length, 0);
  });
});

test('A task with a commentLook shows up as unread and deletes its comment look', function(assert) {
  var comments, paper, task;
  assert.expect(4);
  paper = FactoryGuy.make('paper');
  comments = makeList('comment', 2, 'unread');
  task = FactoryGuy.make('ad-hoc-task', {
    paper: paper,
    body: [],
    comments: comments
  });
  Factory.createPermission('Paper', paper.id, ['view']);
  Factory.createPermission('AdHocTask', task.id, ['view', 'edit']);
  TestHelper.mockFind('paper').returns({
    model: paper
  });
  TestHelper.mockFind('task').returns({
    model: task
  });
  return andThen(function() {
    comments.forEach(function(comment) {
      return TestHelper.handleDelete('comment-look', comment.get('commentLook.id'));
    });
    assert.ok(comments[0].get('commentLook') !== null);
    assert.ok(comments[1].get('commentLook') !== null);
    visit('/papers/' + paper.id + '/tasks/' + task.id);
    return andThen(function() {
      assert.equal(comments[0].get('commentLook'), null);
      return assert.equal(comments[1].get('commentLook'), null);
    });
  });
});
