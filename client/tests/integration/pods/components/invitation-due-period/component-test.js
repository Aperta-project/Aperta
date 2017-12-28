import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('invitation-due-period', 'Integration | Component | invitation due period', {
  integration: true
});

test('it renders', function(assert) {

  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

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
