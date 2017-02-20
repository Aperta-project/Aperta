import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('admin-page/card-catalogue', 'Integration | Component | admin page | card catalogue', {
  integration: true
});

test('it renders a catalogue', function(assert) {
  this.render(hbs`{{admin-page/card-catalogue cards=[]}}`);
  assert.elementFound('.admin-page-catalogue');
});

test('it renders an item for each card given', function(assert) {
  const journal = {name: 'My Journal'};
  const cards = [
    {title: 'Authors', journal: journal},
    {title: 'Tech Check', journal: journal},
    {title: 'Register Decision', journal: journal}
  ];
  this.set('cards', cards);

  this.render(hbs`{{admin-page/card-catalogue cards=cards}}`);
  assert.nElementsFound('.admin-catalogue-item .admin-card-thumbnail', cards.length);
});
