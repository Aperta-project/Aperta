import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import Ember from 'ember';

moduleForComponent(
  'card-content/if',
  'Integration | Component | card content | if then else',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);
    }
  }
);

let ifTemplate = hbs`
{{card-content/if
  class="if-parent"
  scenario=scenario
  owner="this can be anything"
  content=content}}`;

let parent = Ember.Object.extend({
  contentType: 'if',
  condition: 'isEditable',
  text: 'If Parent',
  answerForOwner() {
    return { isEditable: true };
  }
});

test(`it chooses then or else based on the condition`, function(assert) {
  let content = parent.create({
    children: [
      FactoryGuy.make('card-content', {
        contentType: 'short-input',
        text: 'Child 1'
      }),
      FactoryGuy.make('card-content', {
        contentType: 'paragraph-input',
        text: 'Child 2'
      })
    ]
  });

  this.set('scenario', {});
  this.set('scenario.isEditable', true );
  this.set('content', content);
  this.render(ifTemplate);

  assert.elementFound('.card-content-short-input', 'found then content');

  this.set('scenario.isEditable', false );
  assert.elementFound('.card-content-paragraph-input', 'found else content');
});
