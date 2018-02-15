import { moduleForComponent, test } from 'ember-qunit';
import sinon from 'sinon';
import * as AdminCardPermission from 'tahi/lib/admin-card-permission';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('card-editor/permissions/role', 'Integration | Component | card editor | permissions | role', {
  integration: true
});

test('it renders participant checkboxes', function(assert) {
  sinon.stub(AdminCardPermission, 'permissionExists');
  const card = Ember.Object.create({ id: 1 });
  const role = Ember.Object.create({name: 'Foo'});
  this.setProperties({card: card, role: role, noop: sinon.stub()});

  this.render(hbs `{{card-editor/permissions/role
                    role=role
                    card=card
                    turnOnPermission=noop
                    turnOffPermission=noop}}`);

  assert.elementFound('input[name=Foo-manage_participant]');
  assert.elementFound('input[name=Foo-view_participants]');
});
