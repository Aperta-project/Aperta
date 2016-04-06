import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('progress-spinner-message', 'Integration | Component | progress spinner message', {
  integration: true
});

test('it renders', function(assert) {
  this.render(hbs`{{progress-spinner-message}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:" + EOL +
  this.render(hbs`
    {{#progress-spinner-message}}
      template block text
    {{/progress-spinner-message}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});
