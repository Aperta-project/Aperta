// Generated by CoffeeScript 1.10.0
import Ember from 'ember';
import { test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import { paperWithTask } from '../helpers/setups';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';
import win from 'tahi/lib/window-location';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';;
var app, currentPaper, exportUrl, fakeUser, server;

app = null;

server = null;

currentPaper = null;

fakeUser = null;

exportUrl = null;

module('Integration: Paper Docx Download', {
  afterEach: function() {
    return Em.run(function() {
      server.restore();
      Ember.run(function() {
        return TestHelper.teardown();
      });
      return Ember.run(app, 'destroy');
    });
  },
  beforeEach: function() {
    return Em.run(function() {
      app = startApp();
      server = setupMockServer();
      fakeUser = window.currentUserData.user;
      return TestHelper.mockFindAll('discussion-topic', 1);
    });
  }
});

test('show download links on control bar', function(assert) {
  return Ember.run(function() {
    var jobId, mock, paperPayload, paperResponse, records;
    records = paperWithTask('AdHocTask', {
      id: 1,
      title: "Metadata",
      isMetadataTask: true,
      completed: true
    });
    currentPaper = records[0];
    paperPayload = Factory.createPayload('paper');
    console.log("LOG:", "before add records");
    paperPayload.addRecords(records.concat([fakeUser]));
    console.log("LOG:", "after add records");
    paperResponse = paperPayload.toJSON();
    jobId = '232134-324-1234-1234';
    exportUrl = "/api/papers/" + currentPaper.id + "/export?export_format=docx";
    server.respondWith('GET', "/api/papers/" + currentPaper.id, [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify(paperResponse)
    ]);
    server.respondWith('GET', exportUrl, [
      202, {
        "Content-Type": "application/json"
      }, JSON.stringify({
        url: "/api/papers/" + currentPaper.id + "/status/" + jobId
      })
    ]);
    server.respondWith('GET', "/api/papers/" + currentPaper.id + "/status/" + jobId, [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify({
        url: "/api/papers/" + currentPaper.id + "/download.docx"
      })
    ]);
    server.respondWith('GET', "/api/notifications/", [
      204, {
        "Content-Type": "application/json"
      }, JSON.stringify({})
    ]);
    server.respondWith('GET', "/api/journals", [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({
        journals: []
      })
    ]);
    mock = void 0;
    visit("/papers/" + currentPaper.id);
    andThen(function() {
      return assert.ok(true);
    });
    andThen(function() {
      mock = sinon.mock(win);
      return mock.expects("location").withArgs("/api/papers/" + currentPaper.id + "/download.docx").returns(true);
    });
    click('#nav-downloads').then(function() {
      return click('.docx');
    });
    return andThen(function() {
      assert.ok(_.findWhere(server.requests, {
        method: 'GET',
        url: exportUrl
      }), 'Download request made');
      return mock.restore();
    });
  });
});
