import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('admin-page/card-catalogue', 'Integration | Component | admin page | card catalogue', {
  integration: true
});

test('it renders a catalogue', function(assert) {
  const cards = [];
  this.set('cards', cards);
  this.render(hbs`{{admin-page/card-catalogue cards=cards}}`);
  assert.elementFound('.admin-page-catalogue');
});

test('it renders an item for each unarchived card given', function(assert) {
  const journal = {name: 'My Journal'};
  const cards = [
    {title: 'Authors', journal: journal, isNew: false},
    {title: 'Tech Check', journal: journal, isNew: false},
    {title: 'Register Decision', journal: journal, isNew: false},
    {title: 'Archived Card', journal: journal, isNew: false, state: 'archived'}
  ];
  this.set('cards', cards);

  this.render(hbs`{{admin-page/card-catalogue cards=cards}}`);
  assert.nElementsFound('.admin-catalogue-item .admin-card-thumbnail', 3, `doesn't show archived cards`);
});
