import Ember from "ember";
import { module, test } from "qunit";
import startApp from "tahi/tests/helpers/start-app";
import FactoryGuy from "ember-data-factory-guy";
import TestHelper from "ember-data-factory-guy/factory-guy-test-helper";

let App, paper, phase, task, inviteeEmail;

module("Integration: inviting an editor", {
  afterEach() {
    Ember.run(function() {
      TestHelper.teardown();
      App.destroy();
    });
  },

  beforeEach() {
    App = startApp();
    TestHelper.setup(App);

    $.mockjax({url: "/api/admin/journals/authorization", status: 204});
    $.mockjax({url: "/api/user_flows/authorization", status: 204});
    $.mockjax({url: /\/api\/papers\/\d+\/manuscript_manager/, status: 204});
    $.mockjax({url: "/api/formats", status: 200, responseText: {
      import_formats: [],
      export_formats: []
    }});

    inviteeEmail = window.currentUserData.user.email;
    $.mockjax({
      url: /\/api\/filtered_users/,
      status: 200,
      contentType: "application/json",
      responseText: {
        filtered_users: [{ id: 1, full_name: "Aaron", email: inviteeEmail }]
      }
    });

    phase = FactoryGuy.make("phase");
    task = FactoryGuy.make("paper-editor-task", { phase: phase });
    paper = FactoryGuy.make('paper', { phases: [phase], tasks: [task] });
    TestHelper.handleFind(paper);
    TestHelper.handleFindAll('discussion-topic', 1);
  }
});

test("displays the email of the invitee", function(assert) {
  Ember.run(function() {
    TestHelper.handleFind(task);
    visit(`/papers/${paper.id}/workflow`);
    click("#manuscript-manager .card-content:contains('Invite Editor')");
    pickFromSelect2(".editor-select2", inviteeEmail);

    TestHelper.handleCreate("invitation").andReturn({state: "invited"});

    click(".invite-editor-button");

    andThen(function() {
      assert.ok(find(`.overlay-main-work:contains('${inviteeEmail} has been invited to be Editor on this manuscript.')`));
    });
  });
});

test("can withdraw the invitation", function(assert) {
  Ember.run(function() {
    let invitation = FactoryGuy.make("invitation", {email: "foo@bar.com", state: "invited"});
    task.set("invitation", invitation);
    TestHelper.handleFind(task);

    visit(`/papers/${paper.id}/workflow`);
    click("#manuscript-manager .card-content:contains('Invite Editor')");

    andThen(function() {
      let msgEl = find(".invite-editor-text:contains('foo@bar.com has been invited to be Editor on this manuscript.')");
      assert.ok(msgEl[0] !== undefined, "has pending invitation");

      TestHelper.handleDelete("invitation", invitation.id);
      click(".button-primary:contains('Withdraw invitation')");

      andThen(function() {
        assert.equal(task.get('invitation'), null);
      });
    });

  });
});
