import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('not-authenticated', 'Integration | Component | not authenticated', {
  integration: true
});

test('it expects minimalChrome in its container layout', function(assert) {

  this.render(hbs`
    {{#not-authenticated}}
      blah
    {{/not-authenticated}}
  `);

  assert.ok(this.$('div').hasClass('public-body'));
});
