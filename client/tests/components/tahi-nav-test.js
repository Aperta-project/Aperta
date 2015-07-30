import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('tahi-nav', 'TahiNavComponent', {
  integration: true
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs(`
    {{tahi-nav}}
  `));

  assert.equal(this.$('.navigation').length, 1);
});
