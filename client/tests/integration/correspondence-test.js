import Ember from 'ember';
import {
  test
} from 'ember-qunit';
import startApp from '../helpers/start-app';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';

import FactoryGuy from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import formatDate from 'tahi/lib/format-date';

var app, paper, correspondence, server;

app = null;
server = null;
paper = null;
correspondence = null;

moduleForAcceptance('Integration: Correspondence', {
  afterEach: function() {
    server.restore();
    Ember.run(function() {
      return TestHelper.teardown();
    });
    Ember.run(app, app.destroy);
    $.mockjax.clear();
  },
  beforeEach: function() {
    app = startApp();
    TestHelper.setup();
    server = setupMockServer();

    correspondence = FactoryGuy.make('correspondence');
    paper = FactoryGuy.make('paper', {
      correspondence: [correspondence]
    });

    TestHelper.mockPaperQuery(paper);
    TestHelper.mockFindAll('journal', 0);

    Factory.createPermission('Paper', paper.id, ['submit', 'manage_workflow']);
    $.mockjax({
      url: `/api/papers/${paper.get('shortDoi')}`,
      type: 'put',
      status: 204
    });

    $.mockjax({
      type: 'GET',
      url: '/api/feature_flags.json',
      status: 200,
      responseText: {
        CORRESPONDENCE: true
      }
    });
  }
});

function stubEndpointRequestResponse(url, status, json) {
  $.mockjax({
    url: url,
    status: status,
    dataType: 'json',
    responseText: json
  });
}

test('User can view a correspondence record', function(assert) {
  visit('/papers/' + paper.get('shortDoi') + '/correspondence/viewcorrespondence/1');
  return andThen(function() {
    assert.ok(find('.correspondence-overlay'), 'Correspondence Overlay');
    assert.equal(find('.correspondence-date').text().trim(), formatDate(correspondence.get('date'), {}));
    assert.equal(find('.correspondence-sender').text().trim(), correspondence.get('sender'));
    assert.equal(find('.correspondence-recipient').text().trim(), correspondence.get('recipient'));
    assert.equal(find('.correspondence-subject').text().trim(), correspondence.get('subject'));
  });
});

test('User can click on a correspondence to view it\'s recodes', function(assert) {
  visit('/papers/' + paper.get('shortDoi') + '/correspondence');
  click('.correspondence1 a');
  return andThen(function() {
    assert.equal(currentURL(), '/papers/' + paper.get('shortDoi') + '/correspondence/viewcorrespondence/1');
  });
});

test(`Authorized User can see the 'Add Correspondence' button`, (assert) => {
  visit('/papers/' + paper.get('shortDoi') + '/correspondence');
  return andThen(() => {
    assert.textPresent('#add-correspondence-button', 'Add Correspondence');
  });
});

test(`Unauthorized User cannot see the 'Add Correspondence' button`, (assert) => {
  Factory.createPermission('Paper', paper.id, ['submit']);
  $.mockjax({
    url: `/api/papers/${paper.get('shortDoi')}`,
    type: 'put',
    status: 204
  });

  visit('/papers/' + paper.get('shortDoi') + '/correspondence');
  return andThen(() => {
    assert.equal(find('#add-correspondence-button').length, 0);
  });
});

test(`'Add Correspondence' opens a form overlay`, (assert) => {
  let doi = paper.get('shortDoi');
  visit('/papers/' + doi + '/correspondence');
  click('#add-correspondence-button');
  return andThen(() => {
    assert.textPresent('.correspondence-overlay', 'Add Correspondence to History');
    assert.equal(currentURL(), '/papers/' + doi + '/correspondence/new');
  });
});

test(`'Add Correspondence' form`, (assert) => {
  visit('/papers/' + paper.get('shortDoi') + '/correspondence/new');
  return andThen(() => {
    assert.textPresent('.inset-form-control-text', 'Date sent');
    assert.textPresent('.inset-form-control-text', 'Time sent');
    assert.textPresent('.inset-form-control-text', 'Description');
    assert.textPresent('.inset-form-control-text', 'From');
    assert.textPresent('.inset-form-control-text', 'To');
    assert.textPresent('.inset-form-control-text', 'Subject');
    assert.textPresent('.inset-form-control-text', 'CC');
    assert.textPresent('.inset-form-control-text', 'BCC');
    assert.textPresent('.inset-form-control-text', 'Contents');
  });
});

test('Authorized User can create external correspondence', (assert) => {
  let doi = paper.get('shortDoi');

  stubEndpointRequestResponse('/api/papers/' + doi + '/correspondence', 'success', {
    'correspondence': {
      'id': 23,
      'date': '2001-02-13T12:34:00.000Z',
      'subject': 'Physics',
      'recipient': 'to@example.com',
      'sender': 'from@example.com',
      'body': 'This is a very long body message~~~~'
    }
  });

  visit('/papers/' + doi + '/correspondence/new');

  fillIn('.correspondence-date-sent', '02/13/2001');
  fillIn('.correspondence-time-sent', '12:34pm');
  fillIn('.correspondence-description', 'Good Description');
  fillIn('.correspondence-from', 'from@example.com');
  fillIn('.correspondence-to', 'to@example.com');
  fillIn('.correspondence-subject', 'Physics');
  fillIn('.correspondence-cc', 'cc@example.com');
  fillIn('.correspondence-bcc', 'bcc@example.com');
  fillIn('.correspondence-body', 'This is a very long body message~~~~');
  assert.ok(find('.correspondence-submit'));

  // Still haven't figured out how to do this testing in Ember.
  andThen(() => {
    // assert.ok(true);
    // assert.equal(currentURL(), '/papers/' + doi + '/correspondence');
  });
});
