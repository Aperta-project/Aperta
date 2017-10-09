import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';
import wait from 'ember-test-helpers/wait';

moduleForComponent('inline-edit-body-part', 'Integration | Component | inline edit body part', {
  integration: true
});

test('Adding an item', function(assert) {
  const addItem  = sinon.spy();
  this.set('addItem', addItem);
  this.set('editing', true);
  this.set('canManage', true);

  this.render(hbs`{{inline-edit-body-part addItem=addItem editing=editing canManage=canManage}}`);
  const addItemButtonSelector = '.add-item';

  assert.elementFound(addItemButtonSelector, 'There is an add-item button');

  this.$(addItemButtonSelector).click();
  return wait().then(() => {
    assert.ok(addItem.called, 'addItem was called');
  });
});
