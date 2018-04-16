/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import FactoryGuy from 'ember-data-factory-guy';
import Factory from 'tahi/tests/helpers/factory';
import * as TestHelper from 'ember-data-factory-guy';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';

let App, paper, phase, task, inviteeEmail;

moduleForAcceptance('Integration: Inviting an editor', {

  beforeEach() {
    $.mockjax({url: '/api/admin/journals/authorization', status: 204});
    $.mockjax({url: '/api/formats', status: 200, responseText: {
      import_formats: [],
      export_formats: []
    }});
    $.mockjax({url: /\/api\/tasks\/\d+/, type: 'PUT', status: 200, responseText: {}});
    $.mockjax({url: /\/api\/journals/, type: 'GET', status: 200, responseText: { journals: [] }});
    $.mockjax({url: /\/api\/invitations\/\d+\/rescind/, type: 'PUT', status: 200, responseText: {}});

    inviteeEmail = window.currentUserData.user.email;
    $.mockjax({
      url: /api\/tasks\/\d+\/eligible_users\/academic_editors/,
      type: 'GET',
      status: 200,
      contentType: 'application/json',
      responseText: {
        users: [{ id: 1, full_name: 'Aaron', email: inviteeEmail }]
      }
    });

    phase = FactoryGuy.make('phase');
    task  = FactoryGuy.make('paper-editor-task', { phase: phase, letter: '"A letter"', viewable: true });
    paper = FactoryGuy.make('paper', { phases: [phase], tasks: [task] });
    TestHelper.mockPaperQuery(paper);
    TestHelper.mockFindAll('discussion-topic', 1);

    Factory.createPermission('Paper', 1, ['manage_workflow']);
    Factory.createPermission('PaperEditorTask', task.id, ['edit']);
  }
});


test('disables the Compose Invite button until a user is selected', function(assert) {
  Ember.run(function(){
    TestHelper.mockFindRecord('paper-editor-task').returns({ model: task });
    visit(`/papers/${paper.get('shortDoi')}/workflow`);
    click('.card-title:contains("Invite Editor")');

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
    let invitation = FactoryGuy.make('invitation', {email: 'foo@bar.com', state: 'pending'});
    task.set('invitations', [invitation]);
    TestHelper.mockFindRecord('paper-editor-task').returns({model: task});
    TestHelper.mockDelete('invitation', invitation.id);

    visit(`/papers/${paper.get('shortDoi')}/workflow`);
    click(".card-title:contains('Invite Editor')");

    andThen(function() {
      assert.elementFound(`.invitation-item:contains('${invitation.get('email')}')`, 'has pending invitation');
    });

    click('.invitation-item-full-name');
    click('.invitation-item-action-delete');

    andThen(function() {
      assert.equal(task.get('invitation'), null, 'invitation deleted');
    });

  });
});

test('can not delete an invited invitation', function(assert) {
  Ember.run(function() {
    let invitation = FactoryGuy.make('invitation', {email: 'foo@bar.com', state: 'invited'});
    task.set('invitations', [invitation]);
    TestHelper.mockFindRecord('paper-editor-task').returns({model: task});

    visit(`/papers/${paper.get('shortDoi')}/workflow`);
    click(".card-title:contains('Invite Editor')");

    andThen(function() {
      assert.elementFound(`.invitation-item:contains('${invitation.get('email')}')`, 'has pending invitation');
    });

    click('.invitation-item-full-name');
    andThen(function() {
      assert.elementNotFound('.invitation-action-item-delete');
    });
  });
});
