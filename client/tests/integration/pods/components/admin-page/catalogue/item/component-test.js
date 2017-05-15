import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';

moduleForComponent('admin-page/catalogue/item', 'Integration | Component | Admin Page | Catalogue | Item', {
  integration: true
});

test('it renders its contents in a classy div', function(assert) {
  this.render(hbs`
    {{#admin-page/catalogue/item}}
      admin-page catalogue item content goes here.
    {{/admin-page/catalogue/item}}
  `);

  assert.equal(this.$().text().trim(), 'admin-page catalogue item content goes here.');
  assert.elementFound('.admin-catalogue-item');
});

test('it handles click action', function(assert) {

  const clicker = sinon.stub();
  this.on('click', clicker);

  this.render(hbs`
    {{#admin-page/catalogue/item action=(action "click")}}
      admin-page catalogue item content goes here
    {{/admin-page/catalogue/item}}
  `);

  this.$('.admin-catalogue-item').click();

  assert.spyCalled(clicker,
    'Calls click event on passed in action');
});
