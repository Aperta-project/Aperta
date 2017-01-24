import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import { test } from 'ember-qunit';
import { paperWithTask } from '../helpers/setups';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';
import win from 'tahi/lib/window-location';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

let fakeUser, server;

moduleForAcceptance('Integration: Paper Docx Download', {
  afterEach() {
    server.restore();
    TestHelper.teardown();
  },

  beforeEach() {
    server = setupMockServer();
    fakeUser = window.currentUserData.user;
    TestHelper.mockFindAll('discussion-topic', 1);
  }
});

test('show download links on control bar', function(assert) {
  const records = paperWithTask('AdHocTask', {
    id: 1,
    title: 'Metadata',
    isMetadataTask: true,
    completed: true
  });

  let mock = void 0;
  const currentPaper = records[0];
  const versionedTextsURL = `/api/papers/${currentPaper.shortDoi}/versioned_texts`;
  const exportUrl = `/api/papers/${currentPaper.id}/export?export_format=docx&versioned_text_id=1`;
  const paperPayload = Factory.createPayload('paper');
  paperPayload.addRecords(records.concat([fakeUser]));
  const paperResponse = paperPayload.toJSON();
  paperResponse.paper.file_type = 'docx';
  paperResponse.paper.links = { versioned_texts: versionedTextsURL };
  const jobId = '232134-324-1234-1234';

  server.respondWith('GET', `/api/papers/${currentPaper.shortDoi}`, [
    200, { 'Content-Type': 'application/json' }, JSON.stringify(paperResponse)
  ]);

  server.respondWith('GET', exportUrl, [
    202, { 'Content-Type': 'application/json' }, JSON.stringify({
      url: `/api/papers/${currentPaper.id}/status/${jobId}`
    })
  ]);

  server.respondWith('GET', `/api/papers/${currentPaper.id}/status/${jobId}`, [
    200,
    { 'Content-Type': 'application/json' },
    JSON.stringify({ url: `/api/papers/${currentPaper.id}/download.docx` })
  ]);

  server.respondWith('GET', '/api/journals', [
    200, { 'Content-Type': 'application/json' }, JSON.stringify({
      url: `/api/papers/${currentPaper.id}/download.docx`
    })
  ]);

  server.respondWith('GET', '/api/notifications/', [
    204, { 'Content-Type': 'application/json' }, JSON.stringify({})
  ]);

  server.respondWith('GET', '/api/journals', [
    200, { 'Content-Type': 'application/json' }, JSON.stringify({
      journals: []
    })
  ]);

  server.respondWith('GET', versionedTextsURL, [
    200, { 'Content-Type': 'application/json' }, JSON.stringify({
      versioned_texts: [{
        id: 1,
        paper_id: currentPaper.id,
        file_type: 'docx',
      }]
    })
  ]);

  mock = sinon.mock(win);
  mock.expects('location').withArgs(`/api/papers/${currentPaper.id}/download.docx`).returns(true);

  visit(`/papers/${currentPaper.shortDoi}`);
  click('#nav-downloads');
  click('.download-docx');
  andThen(function() {
    assert.ok(_.findWhere(server.requests, {
      method: 'GET',
      url: exportUrl
    }), 'Download request made');

    mock.restore();
  });
});

