import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';

moduleForComponent('left-drawer/drawer', 'Integration | Component | left drawer | drawer', {
  integration: true
});

test('it renders its contents in a classy div', function(assert) {
  this.render(hbs`
    {{#left-drawer/drawer}}
      Drawer bits go here
    {{/left-drawer/drawer}}
  `);

  assert.equal(this.$().text().trim(), 'Drawer bits go here');
  assert.elementFound('.left-drawer.left-drawer-width');
});

test('it renders the title if there is one', function(assert) {
  this.render(hbs`
    {{#left-drawer/drawer title="Drawer title"}}
      Drawer bits go here
    {{/left-drawer/drawer}}
  `);

  assert.equal(this.$('.left-drawer-title').text().trim(),
    'Drawer title',
    'should render the title in title div');
});

test('it calls onToggle when the toggle is clicked', function(assert) {
  const toggler = sinon.stub();
  this.on('toggle', toggler);

  this.render(hbs`
    {{#left-drawer/drawer onToggle=(action "toggle")}}
      Drawer bits go here
    {{/left-drawer/drawer}}
  `);

  this.$('.left-drawer-toggle').click();

  assert.spyCalled(toggler,
    'Calls onToggle when the toggler is toggled');
});
