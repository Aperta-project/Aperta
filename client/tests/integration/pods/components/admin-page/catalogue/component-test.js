import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('admin-page/catalogue', 'Integration | Component | Admin Page | Catalogue', {
  integration: true
});

test('it renders its contents', function(assert) {
  this.render(hbs`
    {{#admin-page/catalogue}}
      Some adminy content goes here.
    {{/admin-page/catalogue}}
  `);
  assert.equal(this.$().text().trim(), 'Some adminy content goes here.');
});
