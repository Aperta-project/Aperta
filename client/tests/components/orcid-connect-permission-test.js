import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from '../helpers/start-app';
import { paperWithTask, addUserAsParticipant, addNestedQuestionToTask } from '../helpers/setups';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app = null;
var server = null;

module('Integration | Component | orcid connect permissions', {
  teardown: function() {
    server.restore();
    return Ember.run(app, app.destroy);
  },
  setup: function() {
    app = startApp();
    server = setupMockServer();
    TestHelper.mockFindAll('journal', 1);
  }
});

test('user with permission sees remove button', function(assert) {
  Factory.createPermission(
      'Journal',
      1,
      ['remove_orcid']);

  visit('/profile');
  assert.ok(!find('.staff-remove-orcid').length);
  assert.ok(find('.remove-orcid'));
});

test('user without permission sees contact message', function(assert) {
  visit('/profile');
  assert.ok(find('.staff-remove-orcid'));
  assert.ok(!find('.remove-orcid').length);
});
