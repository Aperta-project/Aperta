import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from '../helpers/start-app';
import FactoryGuy from 'ember-data-factory-guy';
import Factory from '../helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

let App, paper, phase, task, inviteeEmail;

module('Integration: Inviting a reviewer', {
  afterEach() {
    Ember.run(function() { TestHelper.teardown(); });
    Ember.run(App, 'destroy');
  },

  beforeEach() {
    App = startApp();
    TestHelper.setup(App);

    phase = FactoryGuy.make('phase');
    task  = FactoryGuy.make('paper-reviewer-task', { phase: phase, letter: '"A letter"' });
    paper = FactoryGuy.make('paper', { phases: [phase], tasks: [task] });
    inviteeEmail = window.currentUserData.user.email;

    TestHelper.mockPaperQuery(paper);
    TestHelper.mockFindAll('discussion-topic', 1);

    Factory.createPermission('Paper', 1, ['manage_workflow']);
    Factory.createPermission('PaperReviewerTask', task.id, ['edit']);

    $.mockjax({url: '/api/admin/journals/authorization', status: 204});
    $.mockjax({url: '/api/formats', status: 200, responseText: {
      import_formats: [],
      export_formats: []
    }});
    $.mockjax({url: /\/api\/tasks\/\d+/, type: 'PUT', status: 204, responseText: ''});
    $.mockjax({url: /\/api\/journals/, type: 'GET', status: 200, responseText: { journals: [] }});
    $.mockjax({url: /\/api\/invitations\/1\/rescind/, type: 'PUT', status: 200, responseText: {}});

    $.mockjax({
      url: /api\/tasks\/\d+\/eligible_users\/reviewers/,
      type: 'GET',
      status: 200,
      contentType: 'application/json',
      responseText: {
        users: [{ id: 1, full_name: 'Aaron', email: inviteeEmail }]
      }
    });
  }
});


test('disables the Compose Invite button until a user is selected', function(assert) {
  Ember.run(function(){
    TestHelper.mockFind('task').returns({model: task});
    visit(`/papers/${paper.get('shortDoi')}/workflow`);
    click(".card-title:contains('Invite Reviewers')");

    andThen(function(){
      assert.elementFound(
        '.invitation-email-entry-button.button--disabled',
        'Expected to find Compose Invite button disabled'
      );

      fillIn('#invitation-recipient', inviteeEmail);
    });

    andThen(function(){
      click('.auto-suggest-item:first');
    });

    andThen(function(){
      assert.elementFound(
        '.invitation-email-entry-button:not(.button--disabled)',
        'Expected to find Compose Invite button enabled'
      );
    });
  });
});

test('can delete a pending invitation', function(assert) {
  Ember.run(function() {
    let decision = FactoryGuy.make('decision', 'draft');
    task.set('decisions', [decision]);

    let invitation = FactoryGuy.make('invitation', {
      email: 'foo@bar.com',
      inviteeRole: 'Reviewer',
      state: 'pending'
    });

    decision.set('invitations', [invitation]);

    TestHelper.mockFind('task').returns({model: task});
    TestHelper.mockDelete('invitation', invitation.id);
    TestHelper.mockFind('decision').returns({model: decision});

    visit(`/papers/${paper.get('shortDoi')}/workflow`);
    click(".card-title:contains('Invite Reviewers')");

    andThen(function() {
      let msgEl = find(`.invitation-item:contains('${invitation.get('email')}')`);
      assert.ok(msgEl[0] !== undefined, 'has pending invitation');
    });

    click('.invitation-item-full-name');
    click('.invitation-item-action-delete');

    andThen(function() {
      assert.equal(task.get('invitation'), null, 'invitation deleted');
    });
  });
});

test('can not send or delete a pending invitation from a previous round', function(assert) {
  Ember.run(function() {
    let decision = FactoryGuy.make('decision', 'draft');
    let oldDecision = FactoryGuy.make('decision');
    task.set('decisions', [decision, oldDecision]);

    let invitation = FactoryGuy.make('invitation', {
      email: 'foo@bar.com',
      inviteeRole: 'Reviewer',
      state: 'pending'
    });
    oldDecision.set('invitations', [invitation]);

    TestHelper.mockFind('task').returns({model: task});
    TestHelper.mockFind('decision').returns({model: decision});
    $.mockjax({url: /\/api\/decisions\/2/, type: 'GET', status: 200, responseText: {
      decision: $.extend({id: oldDecision.id}, oldDecision.toJSON())
    }});

    visit(`/papers/${paper.get('shortDoi')}/workflow`);
    click('.card-title:contains("Invite Reviewers")');

    andThen(function() {
      assert.elementNotFound('.active-invitations .invitation-item', 'no active invitations');
      assert.elementFound(`.expired-invitations .invitation-item:contains('${invitation.get('email')}')`, 'has an old pending invitation');
    });

    click('.invitation-item-full-name');

    andThen(function() {
      assert.elementNotFound('.invitation-item-action-delete');
      assert.elementNotFound('.invitation-item-action-send');
    });
  });
});
