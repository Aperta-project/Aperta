import { make, manualSetup }  from 'ember-data-factory-guy';
import FactoryGuy from 'ember-data-factory-guy';
import { test, moduleFor } from 'ember-qunit';
import sinon from 'sinon';
import Ember from 'ember';

moduleFor('service:admin-card-permission', 'Unit | Service | Admin Card Permission', {
  needs: ['service:store', 'model:card-permission', 'model:card', 'model:admin-journal-role'],

  beforeEach: function () {
    manualSetup(this.container);
    this.get = sinon.stub().withArgs('get').returns(this.container.lookup('service:store'));
  }
});

test('findPermission should find a permission for a given card and action with or without explicit role', function(assert) {
  const card1 = make('card');
  const card2 = make('card');
  const roles = FactoryGuy.hasMany('admin-journal-role', 2);

  const perm1 = make('card-permission', {
    roles: roles,
    permissionAction: 'edit',
    filterByCardId: card1.id
  });

  const perm2 = make('card-permission', {
    filterByCardId: card2.id,
    permissionAction: 'edit'
  });
  const checkRole = roles()[0];

  assert.strictEqual(this.subject().findPermission(card1.id, 'edit', perm1, checkRole), perm1);
  assert.strictEqual(this.subject().findPermission(card2.id, 'edit'), perm2);
});

test('findPermissionOrCreate will return an old for a given card and action if it exists', function(assert) {
  const card = make('card');
  const permission = make('card-permission');
  Ember.run(() => {
    const oldPerm = this.subject().findPermissionOrCreate(card.get('id'), 'view');
    assert.strictEqual(oldPerm, permission);
  });
});

test(
  'findPermissionOrCreate with create a new permission for a given card and action if none exists',
  function(assert) {
    const card = make('card');
    Ember.run(() => {
      const newPerm = this.subject().findPermissionOrCreate(card.get('id'), 'edit');
      assert.strictEqual(newPerm.get('permissionAction'), 'edit');
      assert.strictEqual(newPerm.get('filterByCardId'), card.get('id'));
    });
  });

test('addRoleToPermission adds a role to a permission', function(assert) {
  const cardId = '1';
  const role = make('admin-journal-role');
  Ember.run(() => {
    const perm = this.subject().addRoleToPermission(role, cardId, 'edit');
    assert.arrayEqual(perm.get('roles').toArray(), Ember.A([role]));
  });
});

test('removeRoleFromPermission removes a role from a permission', function(assert) {
  const cardId = '1';
  const role = make('admin-journal-role');
  const perm = make(
    'card-permission',
    {
      filterByCardId: cardId,
      roles: [role]
    });
  assert.arrayEqual(perm.get('roles').toArray(), Ember.A([role]));
  Ember.run(() => {
    this.subject().removeRoleFromPermission(role, cardId, perm.get('permissionAction'));
    assert.strictEqual(perm.get('roles.length'), 0);
  });
});

test('addRoleToPermissionSensible adds a role to a view permission', function(assert) {
  const cardId = '1';
  const role = make('admin-journal-role');
  Ember.run(() => {
    const [perm] = this.subject().addRoleToPermissionSensible(role, cardId, 'view');
    assert.arrayEqual(perm.get('roles').toArray(), Ember.A([role]));
    assert.arrayEqual(role.get('cardPermissions').toArray(), Ember.A([perm]));
  });
});

test('addRoleToPermissionSensible adds a role to a view_discussion_footer permission', function(assert) {
  const cardId = '1';
  const role = make('admin-journal-role');
  Ember.run(() => {
    const [perm] = this.subject().addRoleToPermissionSensible(role, cardId, 'view_discussion_footer');
    assert.arrayEqual(perm.get('roles').toArray(), Ember.A([role]));
    assert.arrayEqual(role.get('cardPermissions').toArray(), Ember.A([perm]));
  });
});

test(
  'when addRoleToPermissionSensible adds a role to a edit permission, it also adds a view permission',
  function(assert) {
    const cardId = '1';
    const role = make('admin-journal-role');
    Ember.run(() => {
      const perms = this.subject().addRoleToPermissionSensible(role, cardId, 'edit');
      assert.arrayEqual(perms.map((p)=>p.get('permissionAction')).sort(), ['edit', 'view']);
      perms.forEach((perm)=> {
        assert.arrayEqual(perm.get('roles').toArray(), Ember.A([role]));
      });
      assert.arrayEqual(role.get('cardPermissions').toArray().sort(), perms.toArray().sort());
    });
  });

test(
  'when addRoleToPermissionSensible adds a role to a edit_discussion_footer permission, it also adds a view_discussion_footer permission',
  function(assert) {
    const cardId = '1';
    const role = make('admin-journal-role');
    Ember.run(() => {
      const perms = this.subject().addRoleToPermissionSensible(role, cardId, 'edit_discussion_footer');
      assert.arrayEqual(perms.map((p)=>p.get('permissionAction')).sort(), ['edit_discussion_footer', 'view_discussion_footer']);
      perms.forEach((perm)=> {
        assert.arrayEqual(perm.get('roles').toArray(), Ember.A([role]));
      });
      assert.arrayEqual(role.get('cardPermissions').toArray().sort(), perms.toArray().sort());
    });
  });
