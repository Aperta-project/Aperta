import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';

let App = null;
let payload = {
  'papers': [{
    'id': 4,
    'short_title': 'Testing ABC',
    'title': 'Testing ABC',
    'paper_type': 'Research',
    'submitted_at': '2015-07-06T19:49:17.991Z',
    'related_users': [{
      'name':'Editor',
      'users':[{'id':2,'first_name':'Editor','last_name':'User'}]
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
    $.mockjax({url: '/api/admin/journals/authorization', status: 204});
    $.mockjax({url: '/api/user_flows/authorization', status: 204});
    $.mockjax({url: '/api/comment_looks', status: 200, responseText: {comment_looks: []}});
    $.mockjax({url: '/api/journals', status: 200, responseText: { journals: [] }});
  }
});

test('viewing papers', function(assert) {
  let record   = payload.papers[0];
  let roleName = record.related_users[0].name;
  let lastName = record.related_users[0].users[0].last_name;

  visit('/paper_tracker');
  andThen(function() {
    assert.equal(
      find('.paper-tracker-title-column a').text().trim(),
      record.short_title,
      'Title is displayed'
    );

    assert.ok(
      find('.paper-tracker-members-group').text().trim().match(roleName),
      'Role name is displayed'
    );

    assert.ok(
      find('.paper-tracker-members-group').text().trim().match(lastName),
      'User name is displayed'
    );
  });
});
