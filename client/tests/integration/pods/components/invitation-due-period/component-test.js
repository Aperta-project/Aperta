import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('invitation-due-period', 'Integration | Component | invitation due period', {
  integration: true
});

test('change of input should trigger callback', function(assert) {
  assert.expect(1);
  this.set('display', true);
  this.set('callback', function() { assert.ok(true, 'callback called'); });
  this.render(hbs`{{invitation-due-period display=display onchange=callback}}`);
  this.$('input').val('10').trigger('input');
});

test('negative value is replaced with 1', function(assert) {
  assert.expect(1);
  this.set('display', true);
  this.render(hbs`{{invitation-due-period display=display}}`);

  this.$('input').val('-1').trigger('input');
  assert.equal(this.$('input')[0].value, 1);
});
