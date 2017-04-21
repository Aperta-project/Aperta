import Ember from 'ember';
import { test } from 'ember-qunit';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import setupMockServer from 'tahi/tests/helpers/mock-server';
import { paperWithParticipant } from 'tahi/tests/helpers/setups';
import Factory from 'tahi/tests/helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';

let server = null;
let paper = null;

moduleForAcceptance('Integration: Paper Workflow page', {
  afterEach() {
    server.restore();
  },

  beforeEach() {
    Factory.resetFactoryIds();
    server = setupMockServer();
    TestHelper.mockFindAll('discussion-topic', 1);
    registerCustomAssertions();

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

    $.mockjax({type: 'GET',
      url: '/api/papers',
      status: 200,
      responseText: {papers:[]}
    });

    $.mockjax({type: 'GET',
      url: '/api/papers/' + paper.shortDoi,
      status: 200,
      responseText: paperWithParticipant().toJSON()
    });

    $.mockjax({type: 'POST',
      url: '/api/tasks',
      status: 200,
      responseText: taskPayload
    });

    $.mockjax({type: 'DELETE',
      url: '/api/tasks/1',
      status: 204
    });
    $.mockjax({type: 'DELETE',
      url: '/api/tasks/2',
      status: 204
    });

    $.mockjax({type: 'GET',
      url: '/api/invitations',
      status: 200,
      responseText: {invitations:[]}
    });

    $.mockjax({type: 'GET',
      url: '/api/journals',
      status: 200,
      responseText: {journals:[]}
    });

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
  assert.expect(1);
  var store = getStore();
  Ember.run(() => store.peekAll('permission').invoke('unloadRecord'));

  visit('/papers/' + paper.shortDoi + '/workflow');
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


    assert.mockjaxRequestMade('/api/tasks/2', 'DELETE', 'It sends a DELETE request to the server');
  });
});
