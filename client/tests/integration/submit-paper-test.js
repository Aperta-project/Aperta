import Ember from 'ember';
import { test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import setupMockServer from '../helpers/mock-server';
import { paperWithTask } from '../helpers/setups';
import Factory from '../helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app, currentPaper, fakeUser, server;

app = null;
server = null;
fakeUser = null;
currentPaper = null;

module('Integration: Submitting Paper', {
  afterEach: function() {
    server.restore();
    Ember.run(function() {
      return TestHelper.teardown();
    });
    return Ember.run(app, app.destroy);
  },
  beforeEach: function() {
    var dashboardResponse, paperPayload, paperResponse, records;
    app = startApp();
    server = setupMockServer();
    fakeUser = window.currentUserData.user;
    TestHelper.handleFindAll('discussion-topic', 1);
    records = paperWithTask('Task', {
      id: 1,
      title: "Metadata",
      isMetadataTask: true,
      isSubmissionTask: true,
      completed: true
    });
    currentPaper = records[0];
    paperPayload = Factory.createPayload('paper');
    paperPayload.addRecords(records.concat([fakeUser]));
    paperResponse = paperPayload.toJSON();
    server.respondWith('GET', "/api/papers/" + currentPaper.id, [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify(paperResponse)
    ]);
    dashboardResponse = {
      dashboards: [
        {
          id: 1,
          total_paper_count: 0,
          total_page_count: 0
        }
      ]
    };
    server.respondWith('PUT', "/api/papers/" + currentPaper.id, [
      204, {
        "Content-Type": "application/html"
      }, ""
    ]);
    server.respondWith('PUT', "/api/papers/" + currentPaper.id + "/submit", [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify({
        papers: []
      })
    ]);

    server.respondWith('GET', '/api/journals', [
      200, { 'Content-Type': 'application/json' },
      JSON.stringify({journals:[]})
    ]);

    return server.respondWith('GET', '/api/dashboards', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(dashboardResponse)
    ]);
  }
});

test("User can submit a paper", function(assert) {
  visit("/papers/" + currentPaper.id);
  click(".edit-paper button:contains('Submit')");
  click("button.button-submit-paper");
  return andThen(function() {
    return assert.ok(_.findWhere(server.requests, {
      method: "PUT",
      url: "/api/papers/" + currentPaper.id + "/submit"
    }), "It posts to the server");
  });
});
