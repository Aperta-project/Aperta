import Ember from 'ember';
import {
  test
} from 'ember-qunit';
import Factory from 'tahi/tests/helpers/factory';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';

import FactoryGuy from 'ember-data-factory-guy';
import * as TestHelper from 'ember-data-factory-guy';
import formatDate from 'tahi/lib/aperta-moment';

var app, paper, correspondence, server;

server = null;
paper = null;
correspondence = null;

moduleForAcceptance('Integration: Correspondence', {
  beforeEach: function() {
    correspondence = FactoryGuy.make('correspondence');
    paper = FactoryGuy.make('paper', {
      correspondences: [correspondence]
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

    $.mockjax({
      url: `/api/correspondence/${correspondence.get('id')}`,
      type: 'GET',
      status: 200,
      responseText: {
        correspondence: correspondence.toJSON({includeId: true})
      }
    });

    $.mockjax({
      url: `/api/papers/${paper.get('id')}/correspondence`,
      type: 'GET',
      status: 200,
      responseText: {
        correspondences: [correspondence.toJSON({includeId: true})]
      }
    });
  }
});

test('User can view a correspondence record', function(assert) {
  visit('/papers/' + paper.get('shortDoi') + '/correspondence/viewcorrespondence/1');
  return andThen(function() {
    assert.ok(find('.correspondence-overlay'), 'Correspondence Overlay');
    assert.equal(find('.correspondence-date').text().trim(), formatDate(correspondence.get('utcSentAt'), {}));
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
    assert.equal(find('.attachment-manager').length, 1);
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
    assert.equal($($('.correspondence-error .fa-exclamation-triangle').get(0)).attr('title'), '');
    assert.equal($($('.correspondence-error .fa-exclamation-triangle').get(1)).attr('title'), '');
  });

  // Context: Incorrect Date && Incorrect Time
  visit('/papers/' + paper.get('shortDoi') + '/correspondence/new');
  fillIn('.correspondence-date-sent', '');
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
    assert.equal($($('.correspondence-error .fa-exclamation-triangle').get(0)).attr('title'), 'Invalid Date.');
    assert.equal($($('.correspondence-error .fa-exclamation-triangle').get(1)).attr('title'), 'Invalid Time.');
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
    click('.button-link');

    andThen(() => {
      // When the form is closed, the filled record should not be on the list
      assert.textNotPresent('.td:nth-child(2)', 'Gooder Description');
    });
  });
});

test('click cancel from correspondence edit returns to view correspondence', (assert) => {
  const correspondenceEditUrl = '/papers/' + paper.get('shortDoi') + '/correspondence/' + correspondence.get('id') + '/edit';
  const correspondenceViewUrl = '/papers/' + paper.get('shortDoi') + '/correspondence/viewcorrespondence/' + correspondence.get('id');

  visit(correspondenceEditUrl);
  click('.button-link');

  andThen(() => {
    assert.equal(currentURL(), correspondenceViewUrl);
  });
});

test('Deleting attachment reduces count from 2 to 1', (assert) => {
  const correspondenceEditUrl = '/papers/' + paper.get('shortDoi') + '/correspondence/' + correspondence.get('id') + '/edit';
  const attachmentId = correspondence.get('attachments.firstObject.id');
  $.mockjax({
    url: `/api/papers/${paper.get('id')}/correspondence/${correspondence.get('id')}/attachments/${attachmentId}`,
    type: 'DELETE',
    status: 204
  });

  visit(correspondenceEditUrl);
  andThen(() => {
    assert.equal(find('.attachment-manager .file-link').length, 2);
    click('.delete-attachment:first');

    andThen(() => {
      assert.equal(find('.attachment-manager .file-link').length, 1);
    });
  });
});

test('user is able to edit an external correspondence', (assert) => {
  const editCorrespondence = '/papers/' + paper.get('shortDoi') + '/correspondence/' + correspondence.get('id') + '/edit';
  const viewCorrespondence = '/papers/' + paper.get('shortDoi') + '/correspondence/viewcorrespondence/' + correspondence.get('id');

  $.mockjax({
    url: `/api/papers/${paper.get('id')}/correspondence/${correspondence.get('id')}`,
    type: 'PUT',
    status: 200,
    responseText: {
      correspondence: correspondence.toJSON({includeId: true})
    }
  });

  $.mockjax({
    url: `/api/correspondence/${correspondence.get('id')}`,
    type: 'PUT',
    status: 200,
    responseText: {
      correspondence: correspondence.toJSON({includeId: true})
    }
  });

  visit(editCorrespondence);

  fillIn('.correspondence-description', 'Modified Description');
  fillIn('.correspondence-from', 'niceguy@example.com');
  fillIn('.correspondence-to', 'to@example.com');
  fillIn('.correspondence-subject', 'Test');
  fillIn('.correspondence-cc', 'cc@example.com');
  fillIn('.correspondence-bcc', 'bcc@example.com');
  fillIn('.correspondence-body', 'This is a very long body message~~~~');

  click('.correspondence-submit');

  andThen(() => {
    assert.equal(currentURL(), viewCorrespondence);
  });
});
