import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('left-drawer/prevent-overlap', 'Integration | Component | left drawer | prevent overlap', {
  integration: true
});

test('it renders its contents', function(assert) {
  this.render(hbs`
    {{#left-drawer/prevent-overlap centered=false}}
      Contents
    {{/left-drawer/prevent-overlap}}
  `);

  assert.elementFound('.left-drawer-width-compensator.left-drawer-width');
  assert.equal(this.$('.left-drawer-content').text().trim(), 'Contents');
});


test('it renders', function(assert) {
  this.render(hbs`
    {{#left-drawer/prevent-overlap centered=true}}
      Contents
    {{/left-drawer/prevent-overlap}}
  `);

  assert.elementFound('.left-drawer-width-compensator-centered.left-drawer-width');
  assert.equal(this.$('.left-drawer-content-centered').text().trim(), 'Contents');
});


test('it renders its contents', function(assert) {
  this.render(hbs`
    {{#left-drawer/prevent-overlap}}
      Contents
    {{/left-drawer/prevent-overlap}}
  `);

  assert.elementFound('.left-drawer-width-compensator.left-drawer-width');
  assert.equal(this.$('.left-drawer-content').text().trim(), 'Contents');
});
