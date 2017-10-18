import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import wait from 'ember-test-helpers/wait';

moduleForComponent(
  'card-content/repeat',
  'Integration | Component | card content | repeat (complex)',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      manualSetup(this.container);
      this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    }
  }
);

let template = hbs`{{card-content/repeat
  content=content
  disabled=disabled
  owner=owner
  repetition=repetition
  preview=false
}}`;


let setValue = ($input, newVal) => {
  return $input.val(newVal).trigger('input').trigger('blur');
};

test(`does things`, function(assert) {
  let store = this.container.lookup('service:store');

  $.mockjax({url: '/api/repetitions', type: 'POST', status: 204, responseText: '{}'});

  let content = FactoryGuy.make('card-content', {
    contentType: 'repeat',
    min: 2,
    itemName: 'thing',
    repetitions: [],
    unsortedChildren: [
      FactoryGuy.make('card-content', {
        contentType: 'short-input',
        text: 'Can you answer my simple question?'
      })
    ]
  });

  this.set('content', content);
  this.set('disabled', false);
  this.set('owner', Ember.Object.create());
  this.set('repetition', null);
  this.render(template);

  return wait().then(() => {
    assert.nElementsFound('.card-content-repeat input', 2, 'found input');
  });
});
