import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('card-content/sendback-reason', 'Integration | Component | card content/sendback reason', {
  integration: true
});

test('it renders', function(assert) {

  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{card-content/sendback-reason}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#card-content/sendback-reason}}
      template block text
    {{/card-content/sendback-reason}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});
