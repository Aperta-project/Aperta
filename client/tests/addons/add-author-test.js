import Ember from "ember";
import { module, test } from "qunit";
import startApp from "tahi/tests/helpers/start-app";
import setupMockServer from '../helpers/mock-server';
import FactoryGuy from "ember-data-factory-guy";
import TestHelper from "ember-data-factory-guy/factory-guy-test-helper";

let App, paper, phase, task, server;

module("Integration: adding an author", {
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
        {id: 120, text: 'A question to be checked', value_type: 'boolean', ident: 'author--published_as_corresponding_author' },
        {id: 121, text: 'A question to be checked', value_type: 'boolean', ident: 'author--deceased' },
        {id: 122, text: 'Contributions',            value_type: 'question-set', ident: 'author--contributions' },
        {id: 123, text: 'A question to be checked', value_type: 'boolean', parent_id: 122, ident: 'author--contributions--conceived_and_designed_experiments' },
        {id: 124, text: 'A question to be checked', value_type: 'boolean', parent_id: 122, ident: 'author--contributions--performed_the_experiments' },
        {id: 125, text: 'A question to be checked', value_type: 'boolean', parent_id: 122, ident: 'author--contributions--analyzed_data' },
        {id: 126, text: 'A question to be checked', value_type: 'boolean', parent_id: 122, ident: 'author--contributions--contributed_tools' },
        {id: 127, text: 'A question to be checked', value_type: 'boolean', parent_id: 122, ident: 'author--contributions--contributed_writing' },
        {id: 128, text: 'Other',                    value_type: 'string',  parent_id: 122, ident: 'author--contributions--other' },
      ]
    };

    server.respondWith('GET', "/api/nested_questions?type=Author", [
      200, { 'Content-Type': 'application/json' }, JSON.stringify(response)
    ]);

    server.respondWith('GET', "/api/admin/journals/authorization", [204, { 'Content-Type': 'application/json' }, "" ]);
    server.respondWith('GET', "/api/user_flows/authorization", [204, { 'Content-Type': 'application/json' }, "" ]);
    server.respondWith('GET', "/api/affiliations", [200, { 'Content-Type': 'application/json' }, JSON.stringify([]) ]);
    server.respondWith('GET', "/api/journals", [200, { 'Content-Type': 'application/json' }, JSON.stringify({journals:[]})]);

    phase = FactoryGuy.make("phase");
    task = FactoryGuy.make("authors-task", { phase: phase });
    paper = FactoryGuy.make("paper", { phases: [phase], tasks: [task], editable: true });
    TestHelper.handleFind(paper);
    TestHelper.handleFindAll("discussion-topic", 1);
  }
});

test('can add a new author', function(assert) {
  Ember.run(function() {
    const firstName = 'James';

    TestHelper.handleFind(task);
    TestHelper.handleCreate('author');

    visit(`/papers/${paper.id}/tasks/${task.id}`);
    click('.button-primary:contains("Add a New Author")')
    fillIn('.author-first', firstName);

    click('.author-form-buttons .button-secondary:contains("done")');

    andThen(function() {
      assert.ok(find(`.authors-overlay-item .author-name:contains('${firstName}')`).length);
    });
  });
});
