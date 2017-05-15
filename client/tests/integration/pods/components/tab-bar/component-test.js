import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('tab-bar', 'Integration | Component | Tab Bar', {
  integration: true
});

test('it renders its contents', function(assert) {
  this.render(hbs`
    {{#tab-bar}}
      Some tab related content goes here.
    {{/tab-bar}}
  `);
  assert.equal(this.$().text().trim(), 'Some tab related content goes here.');
  assert.elementFound('.tab-bar');
});
