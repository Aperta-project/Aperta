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

import Ember from 'ember';
import { test } from 'ember-qunit';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import setupMockServer from 'tahi/tests/helpers/mock-server';
import Factory from 'tahi/tests/helpers/factory';
import * as TestHelper from 'ember-data-factory-guy';
import { make, mockFindAll } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';

let server = null;

moduleForAcceptance('Integration: Paper Workflow page', {
  afterEach() {
    server.restore();
  },

  beforeEach() {

    let paper = make('paper', {journal: {id: 1}});
    let user = make('user');
    let task = make('task');
    make('phase', { paper: paper, tasks: [task] });
    make('participation', { user: user, task: task });
    Factory.resetFactoryIds();
    server = setupMockServer();
    TestHelper.mockFindAll('discussion-topic', 1);
    registerCustomAssertions();

    TestHelper.mockPaperQuery(paper);

    $.mockjax({type: 'DELETE',
      url: '/api/tasks/1',
      status: 204
    });

    mockFindAll('journal');
    mockFindAll('paper');
    mockFindAll('invitation');

    Factory.createPermission('Paper', 1, ['manage_workflow']);
    this.paper = paper;
  }
});

test('transition to route without permission fails', function(assert){
  assert.expect(1);
  var store = getStore();
  Ember.run(() => store.peekAll('permission').invoke('unloadRecord'));

  visit('/papers/' + this.paper.get('shortDoi') + '/workflow');
  andThen(function(){
    assert.equal(
      currentPath(),
      'dashboard.index',
      'Should have redirected to the dashboard'
    );
  });
});

test('transition to route with permission succeeds', function(assert){
  assert.expect(1);
  visit('/papers/' + this.paper.get('shortDoi') + '/workflow');

  andThen(function(){
    assert.equal(
      currentPath(),
      'paper.workflow.index',
      'Should have visited the workflow page'
    );
  });
});

test('show delete confirmation overlay on deletion of a Task', function(assert) {
  visit('/papers/' + this.paper.get('shortDoi') + '/workflow');
  andThen(function() {
    $('.card .card-remove').show();
    click('.card .card-remove');
  });

  andThen(function() {
    assert.equal(
      find('h1:contains("about to delete this card from the paper")').length,
      1
    );
    assert.equal(find('h2:contains("Are you sure?")').length, 1);
    assert.equal(find('.overlay button:contains("cancel")').length, 1);

    assert.equal(
      find('.overlay button:contains("Yes, Delete this Card")').length,
      1
    );
  });
});

test('click delete confirmation overlay cancel button', function(assert) {
  visit('/papers/' + this.paper.get('shortDoi') + '/workflow');

  andThen(function() {
    assert.equal(find('.card-title').length, 1);
    $('.card .card-remove').show();
    click('.card .card-remove');
    click('.overlay button:contains("cancel")');
    assert.equal(find('.card-title').length, 1);
  });
});

test('click delete confirmation overlay submit button', function(assert) {
  visit('/papers/' + this.paper.get('shortDoi') + '/workflow');

  andThen(function() {
    assert.equal(find('.card-title').length, 1, 'card exists');
    $('.card .card-remove').show();
    click('.card .card-remove');
    click('.overlay button:contains("Yes, Delete this Card")');
  });

  andThen(function() {
    assert.equal(find('.card-title').length, 0, 'card deleted');


    assert.mockjaxRequestMade('/api/tasks/1', 'DELETE', 'It sends a DELETE request to the server');
  });
});
