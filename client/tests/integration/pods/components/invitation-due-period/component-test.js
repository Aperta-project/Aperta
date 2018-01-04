import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('invitation-due-period', 'Integration | Component | invitation due period', {
  integration: true
});

test('should have error class when input is invalid', function(assert) {
  this.set('display', true);
  this.render(hbs`{{invitation-due-period display=display}}`);
  this.$('input').val('wat').trigger('input');
  assert.elementFound('input.error');
});

test('change of input should trigger callback', function(assert) {
  assert.expect(1);
  this.set('display', true);
  this.set('callback', function() { assert.ok(true, 'callback called'); });
  this.render(hbs`{{invitation-due-period display=display onchange=callback}}`);
  this.$('input').val('10').trigger('input');
});
