import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import Ember from 'ember';

moduleForComponent(
  'card-content/bulleted-list',
  'Integration | Component | card content | bulleted-list',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);
    }
  }
);

let template = hbs`
{{card-content/bulleted-list
  owner="this can be anything"
  content=content}}`;

test(`it renders nested and non-nested lists`,
  function(assert) {
    let content = Ember.Object.create({
      children: [FactoryGuy.make('card-content', 'short-input', { text: 'Child 1' })]
    });

    this.set('content', content);
    this.render(template);
    assert.elementFound('ul.card-content-bulleted-list li');
    assert.elementNotFound('ul.card-content-bulleted-list li ul.card-content-bulleted-list');

    content.children.push(FactoryGuy.make('card-content', 'list'));
    this.set('content', content);
    this.render(template);
    assert.elementsFound('ul.card-content-bulleted-list li', 2);
    assert.elementFound('ul.card-content-bulleted-list li ul.card-content-bulleted-list');
  }
);
