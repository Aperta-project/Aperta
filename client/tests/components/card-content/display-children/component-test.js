import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import Ember from 'ember';

moduleForComponent(
  'card-content/field-set',
  'Integration | Component | card content | display children',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);
    }
  }
);

let template = hbs`
{{card-content/display-children
  class="display-test"
  owner="this can be anything"
  disabled=disabled
  content=content}}`;

let fakeTextContent = Ember.Object.extend({
  contentType: 'text',
  text: 'A piece of card content',
  answerForOwner() {
    return { value: 'foo' };
  }
});

test(`when disabled, it marks its children as disabled`, function(assert) {
  let content = fakeTextContent.create({
    children: [
      FactoryGuy.make('card-content', {
        contentType: 'short-input',
        text: 'Child 1'
      })
    ]
  });
  this.set('content', content);
  this.set('disabled', true);
  this.render(template);
  assert.elementFound(
    '.card-content-short-input input:disabled',
    'found disabled short input'
  );
});
