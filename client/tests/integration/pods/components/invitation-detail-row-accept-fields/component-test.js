import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('invitation-detail-row-accept-fields', 'Integration | Component | invitation detail row accept fields', {
  integration: true
});

test('it renders', function(assert) {

  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{invitation-detail-row-accept-fields}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#invitation-detail-row-accept-fields}}
      template block text
    {{/invitation-detail-row-accept-fields}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});
