import Ember from "ember";
import { module, test } from "qunit";
import startApp from "tahi/tests/helpers/start-app";
import FactoryGuy from "ember-data-factory-guy";
import TestHelper from "ember-data-factory-guy/factory-guy-test-helper";

let App, paper, phase, task;

module("Integration: adding an author", {
  afterEach() {
    Ember.run(function() { TestHelper.teardown(); });
    Ember.run(App, "destroy");
  },

  beforeEach() {
    App = startApp();
    TestHelper.setup(App);

    $.mockjax({url: "/api/admin/journals/authorization", status: 204});
    $.mockjax({url: "/api/user_flows/authorization", status: 204});
    $.mockjax({url: "/api/affiliations", status: 200, responseText: []});

    phase = FactoryGuy.make("phase");
    task = FactoryGuy.make("authors-task", { phase: phase });
    paper = FactoryGuy.make("paper", { phases: [phase], tasks: [task], editable: true });
    TestHelper.handleFind(paper);
    TestHelper.handleFindAll("discussion-topic", 1);
  }
});

test("can add a new author", function(assert) {
  Ember.run(function() {
    let name = "James";

    TestHelper.handleFind(task);
    TestHelper.handleCreate("author");

    visit(`/papers/${paper.id}/tasks/${task.id}`);
    click(".button-primary:contains('Add a New Author')");
    fillIn(".author-name input:first", name);
    click(".author-contributions input:first");
    click(".author-form-buttons .button-secondary:contains('done')");

    andThen(function() {
      assert.ok(find(`.authors-overlay-item .author-name:contains('${name}')`).length);
    });
  });
});
