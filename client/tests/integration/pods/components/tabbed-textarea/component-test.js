import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('tabbed-textarea', 'Integration | Component | tabbed textarea', {
  integration: true
});

test('it renders', function(assert) {

  this.render(hbs`{{tabbed-textarea annotation="blah"}}`);

  assert.ok(this.$().html(), 'it renders');
});

