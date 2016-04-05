import Ember from "ember";
import { module, test } from "qunit";
import startApp from "tahi/tests/helpers/start-app";
import FactoryGuy from "ember-data-factory-guy";
import Factory from '../helpers/factory';
import TestHelper from "ember-data-factory-guy/factory-guy-test-helper";

let App, paper, phase, task, inviteeEmail;

module("Integration: Inviting an editor", {
  afterEach() {
    Ember.run(function() { TestHelper.teardown(); });
    Ember.run(App, "destroy");
  },

  beforeEach() {
    App = startApp();
    TestHelper.setup(App);

    $.mockjax({url: "/api/admin/journals/authorization", status: 204});
    $.mockjax({url: "/api/formats", status: 200, responseText: {
      import_formats: [],
      export_formats: []
    }});
    $.mockjax({url: /\/api\/tasks\/\d+/, type: 'PUT', status: 200, responseText: {}});
    $.mockjax({url: /\/api\/journals/, type: 'GET', status: 200, responseText: { journals: [] }});

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
    task  = FactoryGuy.make("paper-editor-task", { phase: phase, letter: '"A letter"' });
    paper = FactoryGuy.make("paper", { phases: [phase], tasks: [task] });
    TestHelper.handleFind(paper);
    TestHelper.handleFindAll("discussion-topic", 1);

    Factory.createPermission('Paper', 1, ['manage_workflow']);
    Factory.createPermission('PaperEditorTask', task.id, ['edit']);
  }
});


test('disables the Compose Invite button until a user is selected', function(assert) {
  Ember.run(function(){
    TestHelper.handleFind(task);
    visit(`/papers/${paper.id}/workflow`);
    click(".card-content:contains('Invite Editor')");

    andThen(function(){
      assert.ok(
        find('.compose-invite-button.button--disabled').length,
        'Expected to find Compose Invite button disabled'
      );

      fillIn('#invitation-recipient', inviteeEmail);
    });

    andThen(function(){
      click('.auto-suggest-item:first');
    });

    andThen(function(){
      assert.ok(
        find('.compose-invite-button:not(.button--disabled)').length,
        'Expected to find Compose Invite button enabled'
      );
    });
  });
});

test("can withdraw the invitation", function(assert) {
  Ember.run(function() {
    let invitation = FactoryGuy.make("invitation", {email: "foo@bar.com", state: "invited"});
    task.set("invitations", [invitation]);
    TestHelper.handleFind(task);

    visit(`/papers/${paper.id}/workflow`);
    click(".card-content:contains('Invite Editor')");

    andThen(function() {
      let msgEl = find(`.invitation:contains('${invitation.get("email")}')`);
      assert.ok(msgEl[0] !== undefined, "has pending invitation");

      TestHelper.handleDelete("invitation", invitation.id);
      click(".invite-remove");

      andThen(function() {
        assert.equal(task.get('invitation'), null);
      });
    });

  });
});
