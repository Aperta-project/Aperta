import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('admin-page/card-thumbnail', 'Integration | Component | admin page | card thumbnail', {
  integration: true
});

const journal = {name: 'The best journal'};
const card = {name: 'My special card', journal: journal};

test('it shows the name of the card', function(assert) {
  this.set('card', card);
  this.render(hbs`{{admin-page/card-thumbnail card=card}}`);

  assert.textPresent('.admin-card-thumbnail-name', card.name);
});

test("it shows the name of the card's journal", function(assert) {
  this.set('card', card);
  this.render(hbs`{{admin-page/card-thumbnail card=card}}`);

  assert.textPresent('.admin-card-thumbnail-journal', journal.name);
});
