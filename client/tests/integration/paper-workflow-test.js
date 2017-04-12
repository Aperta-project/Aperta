import Ember from 'ember';
import { test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import setupMockServer from '../helpers/mock-server';
import { paperWithParticipant } from '../helpers/setups';
import Factory from '../helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

let app = null;
let server = null;
let paper = null;

module('Integration: Paper Workflow page', {
  afterEach() {
    server.restore();
    Ember.run(app, app.destroy);
  },

  beforeEach() {
    Factory.resetFactoryIds();
    app = startApp();
    server = setupMockServer();
    TestHelper.mockFindAll('discussion-topic', 1);

    let taskPayload = {
      task: {
        id: 1,
        title: 'New Ad-Hoc Task',
        type: 'AdHocTask',
        phase_id: 1,
        paper_id: 1,
        lite_paper_id: 1
      }
    };

    paper = paperWithParticipant();

    server.respondWith('GET', '/api/papers', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({papers:[]})
    ]);

    server.respondWith('GET', '/api/papers/' + paper.shortDoi, [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(paperWithParticipant().toJSON())
    ]);

    server.respondWith('POST', '/api/tasks', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(taskPayload)
    ]);

    server.respondWith('DELETE', '/api/tasks/1', [
      204, {
        'Content-Type': 'application/json'
      }, ''
    ]);
    server.respondWith('DELETE', '/api/tasks/2', [
      204, {
        'Content-Type': 'application/json'
      }, ''
    ]);

    server.respondWith(
      'GET',
      '/api/invitations',
      [
        200,
        { 'content-type': 'application/json'},
        JSON.stringify({invitations:[]})
      ]
    );

    server.respondWith('GET', '/api/journals', [
      200, { 'Content-Type': 'application/json' },
      JSON.stringify({journals:[]})
    ]);

    $.mockjax({
      type: 'GET',
      url: '/api/feature_flags.json',
      status: 200,
      responseText: {
        CORRESPONDENCE: false
      }
    });

    Factory.createPermission('Paper', 1, ['manage_workflow']);

  }
});

test('transition to route without permission fails', function(assert){
  expect(1);
  var store = getStore();
  Ember.run(() => store.peekAll('permission').invoke('unloadRecord'));

  visit('/papers/' + paper.shortDoi + '/workflow');
  andThen(function(){
    assert.equal(
      currentPath(),
      'dashboard.index',
      "Should have redirected to the dashboard"
    );
  });
});

test('transition to route with permission succeeds', function(assert){
  expect(1);
  visit('/papers/' + paper.shortDoi + '/workflow');

  andThen(function(){
    assert.equal(
      currentPath(),
      'paper.workflow.index',
      'Should have visited the workflow page'
    );
  });
});

test('show delete confirmation overlay on deletion of a Task', function(assert) {
  visit('/papers/' + paper.shortDoi + '/workflow');
  andThen(function() {
    $('.card .card-remove').show();
    click('.card .card-remove');
  });

  andThen(function() {
    assert.equal(
      find('h1:contains("about to delete this card forever")').length,
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
  visit('/papers/' + paper.shortDoi + '/workflow');

  andThen(function() {
    assert.equal(find('.card-title').length, 1);
    $('.card .card-remove').show();
    click('.card .card-remove');
    click('.overlay button:contains("cancel")');
    assert.equal(find('.card-title').length, 1);
  });
});

test('click delete confirmation overlay submit button', function(assert) {
  visit('/papers/' + paper.shortDoi + '/workflow');

  andThen(function() {
    assert.equal(find('.card-title').length, 1, 'card exists');
    $('.card .card-remove').show();
    click('.card .card-remove');
    click('.overlay button:contains("Yes, Delete this Card")');
  });

  andThen(function() {
    assert.equal(find('.card-title').length, 0, 'card deleted');

    const req = _.findWhere(server.requests, {
      method: 'DELETE',
      url: '/api/tasks/2'
    });

    assert.equal(req.status, 204, 'It sends DELETE request to the server');
  });
});
