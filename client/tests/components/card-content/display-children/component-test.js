import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import Ember from 'ember';

moduleForComponent(
  'card-content/display-children',
  'Integration | Component | card content | display children',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);
      this.set('repetition', null);
      this.set('owner', Ember.Object.create());
      this.set('preview', false);
    }
  }
);

let template = hbs`
{{card-content/display-children
  class="display-test"
  owner=owner
  disabled=disabled
  repetition=repetition
  preview=preview
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

test(`when wrapperTag is present ('tagless'), the custom class doesn't appear`, function(assert) {
  let content = FactoryGuy.make('card-content', {
        contentType: 'short-input',
        text: 'Child 1',
        wrapperTag: null,
        customClass: 'pretty-colors'
  });
  this.set('content', content);
  this.render(template);
  assert.elementNotFound(
    '.pretty-colors',
    'custom class not visible'
  );
});

test(`when wrapperTag is present, the custom class appears on the wrapper element`, function(assert) {
  let content = FactoryGuy.make('card-content', {
    contentType: 'short-input',
    text: 'Child 1',
    wrapperTag: 'ol',
    customClass: 'pretty-colors'
  });
  this.set('content', content);
  this.render(template);
  assert.elementFound(
    'ol.pretty-colors',
    'custom class and element visible'
  );
});
