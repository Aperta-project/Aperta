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

// A hyptothetical mostly functional sample acceptance test for future use as boiler plate

// import Ember from 'ember';
// import { module, test } from 'qunit';
// import FactoryGuy from 'ember-data-factory-guy';
// import Factory from 'tahi/tests/helpers/factory';
// import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
// import startApp from 'tahi/tests/helpers/start-app';
// import { manualSetup } from 'ember-data-factory-guy';
// import FakeCanService from 'tahi/tests/helpers/fake-can-service';

// import RSVP from 'rsvp';

// let App, paper, papers, phase, task, inviteeEmail, journal;

// const featureFlagServiceStub = Ember.Service.extend ({
//   flags: {
//     CARD_CONFIGURATION: true,
//     EMAIL_TEMPLATE: true
//   },

//   value(flag){
//     return this.get('flags')[flag];
//   }
// });

// module('Acceptance | Admin | Routes', {
//   beforeEach: function() {
//     Ember.run(function () {
//       App = startApp();
//       manualSetup(App.__container__);

//       App.register('service:feature-flag', featureFlagServiceStub);
//       App.register('service:can', FakeCanService);


//       phase = FactoryGuy.make('phase');
//       task  = FactoryGuy.make('paper-reviewer-task', { phase: phase, letter: '"A letter"' });
//       paper = FactoryGuy.make('paper', { phases: [phase], tasks: [task] });
//       journal = FactoryGuy.make('journal');

//       TestHelper.mockFindAll('paper', 1);
//       TestHelper.mockFindAll('invitation', 1);
//       $.mockjax({url: '/api/journals', status: 200, responseText: JSON.stringify({ 'journals':[{'id':journal.id}] })});

//       TestHelper.mockFindAll('admin-journal', 1);
//       TestHelper.mockFindAll('admin-journal-user');
//       TestHelper.mockFindAll('comment-look', 1);

//       Factory.createPermission('Paper', 1, ['manage_workflow']);
//       Factory.createPermission('PaperReviewerTask', task.id, ['edit']);
//       Factory.createPermission('journal', task.id, ['edit']);
//       let can = App.__container__.lookup('service:can');
//       can.allowPermission('administer', journal);

//       $.mockjax({url: '/api/admin/journals/authorization', status: 204});
//       $.mockjax({url: '/api/comment_looks', status: 200});

//     });
//   },

//   afterEach: function() {
//     Ember.run(function () {
//       TestHelper.teardown();
//       App.destroy();
//     });
//   }
// });

// test('admin routes with only manage users permissions', function(assert) {
//   Ember.run(function(){
//     TestHelper.mockFindRecord('task').returns({model: task});
//     visit('/');
//     click('#nav-admin');

//     andThen(function() {
//       assert.async();
//       assert.equal(currentURL(), "/admin/journals/1/users", 'clicking on admin button goes to first journal`s user path');
//     });
//   });
// });

// test('admin routes with only manage users permissions', function(assert) {
//   Ember.run(function(){
//     TestHelper.mockFindRecord('task').returns({model: task});
//     visit('/admin/journals/1/settings');

//     andThen(function() {
//       assert.equal(currentURL(), "/admin/journals/1/users", 'clicking on admin button goes to first journal`s user path');
//     });
//   });
// });
