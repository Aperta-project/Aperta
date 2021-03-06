/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

// Generated by CoffeeScript 1.10.0
import { test } from 'ember-qunit';
import { make, makeList, mockFindRecord, mockFindAll, mockDelete } from 'ember-data-factory-guy';
import setupMockServer from 'tahi/tests/helpers/mock-server';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import Factory from 'tahi/tests/helpers/factory';
import * as TestHelper from 'ember-data-factory-guy';

var paper = null;

moduleForAcceptance('Integration: Commenting', {
  beforeEach: function() {
    paper = make('paper');
    setupMockServer();
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
    var paperResponse = paper.toJSON();
    paperResponse['id'] = 1;
    $.mockjax({
      url: '/api/papers/' + paper.get('shortDoi'),
      status: 200,
      responseText: {
        paper: paperResponse
      }
    });

    TestHelper.mockPaperQuery(paper);
    return mockFindAll('discussion-topic', 1);
  }
});

test('A card with more than 5 comments has the show all comments button', function(assert) {
  var comments, task;
  assert.expect(3);
  comments = makeList('comment', 10);
  task = make('ad-hoc-task', {
    paper: paper,
    comments: comments,
    body: []
  });
  Factory.createPermission('Paper', paper.id, ['view']);
  Factory.createPermission('AdHocTask', task.id,
                          ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer']);
  TestHelper.mockPaperQuery(paper);
  mockFindRecord('task').returns({
    json: {task: {type: 'ad-hoc-task', id: task.id}}
  });
  visit('/papers/' + (paper.get('shortDoi')) + '/tasks/' + (task.get('id')));
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
  paper = make('paper');
  comments = makeList('comment', 3);
  task = make('ad-hoc-task', {
    paper: paper,
    body: [],
    comments: comments
  });
  Factory.createPermission('Paper', paper.id, ['view']);
  Factory.createPermission('AdHocTask', task.id,
                          ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer']);
  TestHelper.mockPaperQuery(paper);
  mockFindRecord('task').returns({
    json: {task: {type: 'ad-hoc-task', id: task.id}}
  });
  visit('/papers/' + (paper.get('shortDoi')) + '/tasks/' + (task.get('id')));
  return andThen(function() {
    assert.ok(find('.load-all-comments').length === 0);
    assert.equal(find('.message-comment').length, 3, 'All messages displayed');
    return assert.equal(find('.message-comment.unread').length, 0);
  });
});

test('A card without comment view permissions can not see the discussion section', function(assert) {
  var comments, paper, task;
  assert.expect(4);
  paper = make('paper');
  comments = makeList('comment', 3);
  task = make('ad-hoc-task', {
    paper: paper,
    body: [],
    comments: comments
  });
  Factory.createPermission('Paper', paper.id, ['view']);
  Factory.createPermission('AdHocTask', task.id,
                          ['view', 'edit']);
  TestHelper.mockPaperQuery(paper);
  mockFindRecord('task').returns({
    json: {task: {type: 'ad-hoc-task', id: task.id}}
  });
  visit('/papers/' + (paper.get('shortDoi')) + '/tasks/' + (task.get('id')));
  return andThen(function() {
    assert.ok(find('.overlay-discussion-board').length === 0);
    assert.ok(find('.load-all-comments').length === 0);
    assert.equal(find('.message-comment').length, 0, 'No messages displayed');
    return assert.equal(find('.message-comment.unread').length, 0);
  });
});

test('A card with discussion view permissions but not discussion edit permissions can not edit the discussion section', function(assert) {
  var comments, paper, task;
  assert.expect(6);
  paper = make('paper');
  comments = makeList('comment', 3);
  task = make('ad-hoc-task', {
    paper: paper,
    body: [],
    comments: comments
  });
  Factory.createPermission('Paper', paper.id, ['view']);
  Factory.createPermission('AdHocTask', task.id,
                          ['view', 'edit', 'view_discussion_footer']);
  TestHelper.mockPaperQuery(paper);
  mockFindRecord('task').returns({
    json: {task: {type: 'ad-hoc-task', id: task.id}}
  });

  visit('/papers/' + (paper.get('shortDoi')) + '/tasks/' + (task.get('id')));
  return andThen(function() {
    assert.ok(find('.participant-selector').length === 0);
    assert.ok(find('.load-all-comments').length === 0);
    assert.ok(find('.overlay-discussion-board').length === 1);
    assert.ok(find('.overlay-discussion-board .comment-board-form').length === 0);
    assert.equal(find('.message-comment').length, 3, 'All messages displayed');
    return assert.equal(find('.message-comment.unread').length, 0);
  });
});

test('A card with discussion view permissions and discussion edit permissions can view and edit the discussion section', function(assert) {
  var comments, paper, task;
  assert.expect(6);
  paper = make('paper');
  comments = makeList('comment', 3);
  task = make('ad-hoc-task', {
    paper: paper,
    body: [],
    comments: comments
  });
  Factory.createPermission('Paper', paper.id, ['view']);
  Factory.createPermission('AdHocTask', task.id,
                          ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer']);
  TestHelper.mockPaperQuery(paper);
  mockFindRecord('task').returns({
    json: {task: {type: 'ad-hoc-task', id: task.id}}
  });
  visit('/papers/' + (paper.get('shortDoi')) + '/tasks/' + (task.get('id')));
  return andThen(function() {
    assert.ok(find('.participant-selector').length === 1);
    assert.ok(find('.overlay-discussion-board').length === 1);
    assert.ok(find('.overlay-discussion-board .comment-board-form').length === 1);
    assert.ok(find('.load-all-comments').length === 0);
    assert.equal(find('.message-comment').length, 3, 'All messages displayed');
    return assert.equal(find('.message-comment.unread').length, 0);
  });
});

test('A task with a commentLook shows up as unread and deletes its comment look', function(assert) {
  var comments, paper, task;
  assert.expect(4);
  paper = make('paper');
  comments = makeList('comment', 2, 'unread');
  task = make('ad-hoc-task', {
    paper: paper,
    body: [],
    comments: comments
  });
  Factory.createPermission('Paper', paper.id, ['view']);
  Factory.createPermission('AdHocTask', task.id,
                          ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer']);
  TestHelper.mockPaperQuery(paper);
  mockFindRecord('task').returns({
    json: {task: {type: 'ad-hoc-task', id: task.id}}
  });
  return andThen(function() {
    comments.forEach(function(comment) {
      return mockDelete('comment-look', comment.get('commentLook.id'));
    });
    assert.ok(comments[0].get('commentLook') !== null);
    assert.ok(comments[1].get('commentLook') !== null);
    visit('/papers/' + paper.get('shortDoi') + '/tasks/' + task.id);
    return andThen(function() {
      assert.equal(comments[0].get('commentLook'), null);
      return assert.equal(comments[1].get('commentLook'), null);
    });
  });
});
