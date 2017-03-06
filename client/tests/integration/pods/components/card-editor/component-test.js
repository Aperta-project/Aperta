import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';


moduleForComponent('card-editor', 'Integration | Component | card editor', {
  integration: true
});

test('it renders subcontent', function(assert) {
  const card = Ember.Object.create({});
  this.set('card', card);

  this.render(hbs`
    {{#card-editor card=card}}
      <div class='subcontent'>hi there</div>
    {{/card-editor}}
  `);

  assert.textPresent('.subcontent', 'hi there');
});

test('it renders the header', function(assert) {
  const card = Ember.Object.create({});
  this.set('card', card);

  this.render(hbs`
    {{card-editor card=card}}
  `);

  assert.elementFound('.card-editor-header');
});
