// A hyptothetical mostly functional sample acceptance test for future use as boiler plate

// import Ember from 'ember';
// import { module, test } from 'qunit';
// import FactoryGuy from 'ember-data-factory-guy';
// import Factory from '../helpers/factory';
// import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
// import startApp from 'tahi/tests/helpers/start-app';
// import { manualSetup } from 'ember-data-factory-guy';
// import FakeCanService from '../helpers/fake-can-service';

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
//     TestHelper.mockFind('task').returns({model: task});
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
//     TestHelper.mockFind('task').returns({model: task});
//     visit('/admin/journals/1/settings');

//     andThen(function() {
//       assert.equal(currentURL(), "/admin/journals/1/users", 'clicking on admin button goes to first journal`s user path');
//     });
//   });
// });
