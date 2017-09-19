import Ember from 'ember';
import {
  test
} from 'ember-qunit';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';

import * as TestHelper from 'ember-data-factory-guy';
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
      return TestHelper.mockTeardown();
    });
    Ember.run(app, app.destroy);
    $.mockjax.clear();
  },
  beforeEach: function() {
    app = this.application;
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
      url: `/api/papers/${paper.get('id')}/correspondence/${correspondence.get('id')}`,
      type: 'GET',
      status: 200,
      responseText: {
        correspondence: correspondence.toJSON({includeId: true})
      }
    });
  }
});

test('User can view a correspondence record', function(assert) {
  visit('/papers/' + paper.get('shortDoi') + '/correspondence/viewcorrespondence/1');
  return andThen(function() {
    assert.ok(find('.correspondence-overlay'), 'Correspondence Overlay');
    assert.equal(find('.correspondence-date').text().trim(), formatDate(correspondence.get('date'), {}));
    assert.equal(find('.correspondence-sender').text().trim(), correspondence.get('sender'));
    assert.equal(find('.correspondence-recipient').text().trim(), correspondence.get('recipient'));
    assert.equal(find('.correspondence-subject').text().trim(), correspondence.get('subject'));
    assert.equal(find('#correspondence-attachment-paperclip').length, 1);
    assert.equal(find('.correspondence-attachment-link .file-link').length, 2);
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

test('Date and Time [format] are properly validated', (assert) => {

  // Context: Absent Date && Absent Time
  visit('/papers/' + paper.get('shortDoi') + '/correspondence/new');
  fillIn('.correspondence-description', 'Good Description');
  fillIn('.correspondence-from', 'from@example.com');
  fillIn('.correspondence-to', 'to@example.com');
  fillIn('.correspondence-subject', 'Physics');
  fillIn('.correspondence-cc', 'cc@example.com');
  fillIn('.correspondence-bcc', 'bcc@example.com');
  fillIn('.correspondence-body', 'This is a very long body message~~~~');
  click('.correspondence-submit');

  andThen(() => {
    assert.equal($($('.inset-form-control .fa-exclamation-triangle').get(0)).attr('title'), 'Invalid Date. Format MM/DD/YYYY');
    assert.equal($($('.inset-form-control .fa-exclamation-triangle').get(1)).attr('title'), 'Invalid Time. Format hh:mm a');
  });

  // Context: Incorrect Date && Incorrect Time
  visit('/papers/' + paper.get('shortDoi') + '/correspondence/new');
  fillIn('.correspondence-date-sent', 'some date');
  fillIn('.correspondence-time-sent', 'some time');
  fillIn('.correspondence-description', 'Good Description');
  fillIn('.correspondence-from', 'from@example.com');
  fillIn('.correspondence-to', 'to@example.com');
  fillIn('.correspondence-subject', 'Physics');
  fillIn('.correspondence-cc', 'cc@example.com');
  fillIn('.correspondence-bcc', 'bcc@example.com');
  fillIn('.correspondence-body', 'This is a very long body message~~~~');
  click('.correspondence-submit');

  andThen(() => {
    assert.equal($($('.inset-form-control .fa-exclamation-triangle').get(0)).attr('title'), 'Invalid Date. Format MM/DD/YYYY');
    assert.equal($($('.inset-form-control .fa-exclamation-triangle').get(1)).attr('title'), 'Invalid Time. Format hh:mm a');
  });
});

test('Invalid Records are not on list when process is aborted', (assert) => {
  visit('/papers/' + paper.get('shortDoi') + '/correspondence/new');
  fillIn('.correspondence-date-sent', 'some date');
  fillIn('.correspondence-time-sent', 'some time');
  fillIn('.correspondence-description', 'Gooder Description');
  fillIn('.correspondence-from', ''); // Invalidates the record on server
  fillIn('.correspondence-to', 'to@example.com');
  fillIn('.correspondence-subject', 'Physics');
  fillIn('.correspondence-cc', 'cc@example.com');
  fillIn('.correspondence-bcc', 'bcc@example.com');
  fillIn('.correspondence-body', 'This is a very long body message~~~~');
  click('.correspondence-submit'); //

  andThen(() => {
    // Validation failed so the form should remain on the same page
    assert.equal(currentURL(), '/papers/' + paper.get('shortDoi') + '/correspondence/new');
    click('.overlay-close');

    andThen(() => {
      // When the form is closed, the filled record should not be on the list
      assert.textNotPresent('.td:nth-child(2)', 'Gooder Description');
    });
  });
});
