import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from '../helpers/start-app';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';
import { make } from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

moduleForAcceptance('Integration: orcid connect permissions', {
  beforeEach: function() {
    let journal = make('journal');
    TestHelper.mockFindAll('journal').returns({models: [journal]});
    TestHelper.mockFind('journal').returns({model: journal});
    Factory.createPermission(
      'User',
      1,
      ['view']);
  }
});

test('user without permission sees contact message', function(assert) {
  visit('/profile');

  andThen(function() {
    assert.ok(find('.staff-remove-orcid'));
    assert.ok(!find('.remove-orcid').length);
  });
});

test('user with permission sees remove button', function(assert) {
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


