import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('expanding-textarea', 'Integration | Component | expanding textarea', {
  integration: true
});

test('it renders a textarea when no block is provided', function(assert) {
  this.render(hbs`{{expanding-textarea}}`);

  assert.equal(this.$('textarea').length, 1, 'there is a textarea');
});

test('it lets the block render a textarea if one is provided', function(assert) {
  this.render(hbs`
    {{#expanding-textarea}}
      <textarea class="test"></textarea>
    {{/expanding-textarea}}
   `);

  assert.equal(this.$('textarea.test').length, 1, 'the block renders the textarea');
  assert.equal(this.$('textarea').length, 1, 'there is only one textarea');
});
