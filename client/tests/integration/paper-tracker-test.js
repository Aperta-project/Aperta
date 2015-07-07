import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';

let App = null;
let payload = {
  "papers": [{ 
    "id": 4,
    "display_title": "Testing ABC",
    "paper_type": "Research",
    "submitted_at": "2015-07-06T19:49:17.991Z",
    "roles": [{
      "name":"Editor",
      "users":[{"id":2,"first_name":"Editor","last_name":"User"}]
    }]
  }]
};

module('Integration: Paper Tracker', {
  afterEach: function() {
    Ember.run(function() {
      App.destroy();
    });
  },

  beforeEach: function() {
    App = startApp();

    $.mockjax({url: '/api/paper_tracker', status: 200, responseText: payload});
  }
});

test('clicking the feedback button sends feedback to the backend', function(assert) {
  let record   = payload.papers[0];
  let roleName = record.roles[0].name;
  let lastName = record.roles[0].users[0].last_name;

  visit('/paper_tracker');
  andThen(function() {
    assert.equal(find('.paper-tracker-title-column a').text(), record.display_title, 'Title is displayed');
    assert.ok(find('.paper-tracker-members-group').text().match(roleName), 'Role name is displayed');
    assert.ok(find('.paper-tracker-members-group').text().match(lastName), 'User name is displayed');
  });
});
