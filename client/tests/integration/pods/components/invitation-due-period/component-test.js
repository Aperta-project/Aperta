import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('invitation-due-period', 'Integration | Component | invitation due period', {
  integration: true
});

test('it renders', function(assert) {
  this.render(hbs`{{invitation-due-period}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#invitation-due-period}}
      template block text
    {{/invitation-due-period}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});

test('only displays the input if display is true', function(assert) {
  this.set('display', true);
  this.render(hbs`{{invitation-due-period display=display}}`);
  assert.ok(this.$('input').length === 1, 'should have one input element');
  this.set('display', false);
  this.render(hbs`{{invitation-due-period display=display}}`);
  assert.ok(!this.$('input').length, 'should have no input element');
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
