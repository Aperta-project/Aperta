import { make, manualSetup }  from 'ember-data-factory-guy';
import { test, moduleFor } from 'ember-qunit';
import sinon from 'sinon';
import Ember from 'ember';

moduleFor('service:admin-card-permission', 'Unit | Service | Admin Card Permission', {
  needs: ['service:store', 'model:card-permission', 'model:card', 'model:admin-journal-role'],

  beforeEach: function () {
    manualSetup(this.container);
  }
});

test('findPermission should find a permission for a given card and action', function(assert) {
  const card = make('card');
  const permission = make('card-permission');
  this.get = sinon.stub().withArgs('get').returns(this.container.lookup('service:store'));
  assert.equal(this.subject().findPermission(card, 'view'), permission);
});

test('findPermissionOrCreate will return an old for a given card and action if it exists', function(assert) {
  const card = make('card');
  const permission = make('card-permission');
  this.get = sinon.stub().withArgs('get').returns(this.container.lookup('service:store'));
  Ember.run(() => {
    const oldPerm = this.subject().findPermissionOrCreate(card, 'view');
    assert.equal(oldPerm, permission);
  });
});

test(
  'findPermissionOrCreate with create a new permission for a given card and action if none exists',
  function(assert) {
    const card = make('card');
    this.get = sinon.stub().withArgs('get').returns(this.container.lookup('service:store'));
    Ember.run(() => {
      const newPerm = this.subject().findPermissionOrCreate(card, 'edit');
      assert.equal(newPerm.get('permissionAction'), 'edit');
      assert.equal(newPerm.get('filterByCardId'), card.get('id'));
    });
  });
