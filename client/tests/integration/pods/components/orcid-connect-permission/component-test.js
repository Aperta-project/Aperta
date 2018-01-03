import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import setupMockServer from 'tahi/tests/helpers/mock-server';
import Factory from 'tahi/tests/helpers/factory';
import { make } from 'ember-data-factory-guy';
import * as TestHelper from 'ember-data-factory-guy';

moduleForAcceptance('Integration: orcid connect permissions', {
  beforeEach: function() {
    let journal = make('journal');
    TestHelper.mockFindAll('journal').returns({models: [journal]});
    TestHelper.mockFindRecord('journal').returns({model: journal});
  }
});

test('user without permission sees contact message', function(assert) {
  Factory.createPermission(
    'User',
    1,
    ['view']);
  Factory.createPermission(
    'Journal',
    1,
    ['']);

  visit('/profile');

  andThen(function() {
    assert.ok(find('.staff-remove-orcid'));
    assert.ok(!find('.remove-orcid').length);
  });
});

test('user with permission sees remove button', function(assert) {
  Factory.createPermission(
    'User',
    1,
    ['view']);
  Factory.createPermission(
    'Journal',
    1,
    ['remove_orcid']);

  visit('/profile');

  andThen(function() {
    assert.ok(!find('.staff-remove-orcid').length);
    assert.ok(find('.remove-orcid'));
  });
});
