import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('left-drawer', 'Integration | Component | left drawer', {
  integration: true
});


test('it renders its contents', function(assert) {
  this.render(hbs`
    {{#left-drawer}}
      A page goes here
    {{/left-drawer}}
  `);
  assert.equal(this.$().text().trim(), 'A page goes here');
});

test('it renders with an open drawer by default', function(assert) {
  this.render(hbs`
    {{#left-drawer}}
      A page goes here
    {{/left-drawer}}
  `);

  assert.elementFound(
    '.left-drawer-page.left-drawer-open',
    'should default to an open drawer'
  );
});


test('it renders a closed drawer if told to', function(assert) {
  this.render(hbs`
    {{#left-drawer open=false}}
      A page goes here
    {{/left-drawer}}
  `);

  assert.elementFound(
    '.left-drawer-page.left-drawer-closed',
    'should show a closed drawer'
  );
});


test('it closes and opens the drawer when toggle is called', function(assert) {
  this.render(hbs`
    {{#left-drawer as |toggle|}}
      {{left-drawer/drawer onToggle=toggle}}
    {{/left-drawer}}
  `);

  this.$('.left-drawer-toggle').click();

  assert.elementFound(
    '.left-drawer-page.left-drawer-closed',
    'should show a closed drawer after toggling'
  );

  this.$('.left-drawer-toggle').click();

  assert.elementFound(
    '.left-drawer-page.left-drawer-open',
    'should show a open drawer after toggling'
  );
});
