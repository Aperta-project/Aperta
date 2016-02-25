import Ember from "ember";
import { module, test } from "qunit";
import startApp from "tahi/tests/helpers/start-app";
import setupMockServer from '../helpers/mock-server';
import FactoryGuy from "ember-data-factory-guy";
import Factory from '../helpers/factory';
import TestHelper from "ember-data-factory-guy/factory-guy-test-helper";

let App, paper, phase, task, server, taskPayload, taskResponse, fakeUser;

module("Integration: data", {
  afterEach() {
    Ember.run(function() { TestHelper.teardown(); });
    Ember.run(App, "destroy");
  },

  beforeEach() {
    App = startApp();
    server = setupMockServer();
    TestHelper.setup(App);

    const response = {
      nested_questions: [
        {id: 120, text: 'A question to be checked', value_type: 'boolean', ident: 'data-availability--data_fully_available' },
        {id: 121, text: 'A question to be checked', value_type: 'string', ident: 'data-availability--data_location' }
      ]
    };
    server.respondWith('GET', "/api/nested_questions?type=DataAvailability", [
      200, { 'Content-Type': 'application/json' }, JSON.stringify(response)
    ]);

    server.respondWith('GET', "/api/admin/journals/authorization", [204, { 'Content-Type': 'application/json' }, "" ]);
    server.respondWith('GET', "/api/user_flows/authorization", [204, { 'Content-Type': 'application/json' }, "" ]);
    server.respondWith('GET', "/api/affiliations", [200, { 'Content-Type': 'application/json' }, JSON.stringify([]) ]);
    server.respondWith('GET', "/api/journals", [200, { 'Content-Type': 'application/json' }, JSON.stringify({journals:[]})]);

    phase = FactoryGuy.make("phase");

    task = FactoryGuy.make("data-availability-task", { phase: phase });

    paper = FactoryGuy.make("paper", { phases: [phase], tasks: [task], editable: true });
    TestHelper.handleFind(paper);
    TestHelper.handleFindAll("discussion-topic", 1);
    Factory.createPermission('DataAvailabilityTask', task.id, ['edit']);
  }
});

test('can see the data availability questions', function(assert) {
  Ember.run(function() {
    TestHelper.handleFind(task);

    visit(`/papers/${paper.id}/tasks/${task.id}`);

    andThen(function() {
      assert.equal(find(`.question-text`).length, 1);
    });
  });
});
