import Ember from 'ember';
import { test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import setupMockServer from '../helpers/mock-server';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import Factory from '../helpers/factory';

var respondAuthorized, respondUnauthorized, setCurrentUserAdmin;

let app = null;
let server = null;

module('Integration: Navbar', {
  afterEach() {
    server.restore();
    Ember.run(app, app.destroy);
    return Ember.run(function() {
      return TestHelper.teardown();
    });
  },

  beforeEach() {
    app = startApp();
    server = setupMockServer();
    TestHelper.handleFindAll('paper', 0);
    TestHelper.handleFindAll('invitation', 0);

    let dashboardResponse = {
      dashboards: [
        {
          id: 1
        }
      ]
    };

    server.respondWith('GET', '/api/dashboards', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(dashboardResponse)
    ]);

    server.respondWith('GET', "/api/journals", [
      200, {
        'Content-Type': 'application/json' },
        JSON.stringify({journals:[]})
    ]);
  }
});

respondAuthorized = function() {
  var adminJournalsResponse;
  adminJournalsResponse = {
    admin_journals: [
      {
        id: 1,
        name: 'Test Journal of America'
      }
    ]
  };

  server.respondWith('GET', '/api/admin/journals', [
    200, {
      'Content-Type': 'application/json'
    }, JSON.stringify(adminJournalsResponse)
  ]);

  server.respondWith('GET', '/api/admin/journals/authorization', [
    204, {
      'Content-Type': 'application/html'
    }, ''
  ]);
};

respondUnauthorized = function() {
  server.respondWith('GET', '/api/admin/journals/authorization', [
    403, {
      'content-type': 'application/html'
    }, ''
  ]);
};

setCurrentUserAdmin = function(bool) {
  const store = getStore();
  const userId = getCurrentUser().get('id');

  return store.find('user', userId).then(function(currentUser) {
    return currentUser.set('admin', bool);
  });
};

test('all users can see their username', function(assert) {
  respondUnauthorized();

  visit('/').then(function() {
    setCurrentUserAdmin(false);
  });

  andThen(function() {
    assert.equal(
      find('#profile-dropdown-menu:contains("Fake User")').length,
      1
    );
  });
});

test('(200 response) can see the Admin link', function(assert) {
  respondAuthorized();
  visit('/');
  andThen(function() {
    assert.equal(find('.main-nav:contains("Admin")').length, 1);
  });
});

test('(403 response) cannot see the Admin link', function(assert) {
  respondUnauthorized();
  visit('/');
  andThen(function() {
    assert.equal(find('.main-nav:contains("Admin")').length, 0);
  });
});

test('(200 response) with permission can see Paper Tracker link', function(assert) {
  Ember.run(function(){
    var store = getStore();
    store.createRecord('journal', {
      id: 1,
      name: 'Test Journal of America'
    });

    Factory.createPermission('Journal', 1, ['view_paper_tracker']);
    Ember.run(function() {
    andThen(function() {
      respondAuthorized();
      visit('/');
      andThen(function() {
        assert.equal(find('#nav-paper-tracker').length, 1,
                     'paper tracker link is shown');
      });
    });
});
  });
});

test('(200 response) without permission Paper Tracker link is hidden', function(assert) {
  Ember.run(function(){
    var store = getStore();
    store.createRecord('journal', {
      id: 1,
      name: 'Test Journal of America'
    });

    andThen(function() {
      respondAuthorized();
      visit('/');
      andThen(function() {
        assert.equal(find('#nav-paper-tracker').length, 0,
                     'paper tracker link is shown');
      });
    });
  });
});
