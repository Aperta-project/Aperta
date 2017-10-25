import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import { manualSetup, make } from 'ember-data-factory-guy';
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
    },

    afterEach() {
      $.mockjax.clear();
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

test(`it adds a repetition between two other repetitions`, function(assert) {
  let store = this.container.lookup('service:store');

  let repetitionIdSeed = 110;
  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, response: function() {
    this.responseText = {
      repetition: { id: repetitionIdSeed++ },
    };
  }});

  let content = make('card-content', {
    contentType: 'repeat',
    min: 2,
    max: null,
    itemName: 'thing',
    repetitions: [],
    unsortedChildren: [
      make('card-content', {
        contentType: 'short-input',
        text: 'Can you answer my simple question?'
      })
    ]
  });

  this.set('content', content);
  this.set('disabled', false);
  this.set('owner', make('custom-card-task'));
  this.set('repetition', null);
  this.render(template);

  return wait().then(() => {
    assert.nElementsFound('.repeated-block', 2, 'found initial repetitions');
    this.$('.add-repetition:first').click();

    return wait().then(() => {
      assert.nElementsFound('.repeated-block', 3, 'new repetition was added');
      assert.equal(store.peekRecord('repetition', 110).get('position'), 0, 'the initial repetition created should be first in the list');
      assert.equal(store.peekRecord('repetition', 112).get('position'), 1, 'the newly created repetition should be second in the list');
    });
  });
});

test(`it builds an inner child repeater if inner child repeater has a minimum`, function(assert) {
  let repetitionIdSeed = 110;
  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, response: function() {
    this.responseText = {
      repetition: { id: repetitionIdSeed++ },
    };
  }});

  let content = make('card-content', {
    contentType: 'repeat',
    min: 0,
    itemName: 'outer thing',
    repetitions: [],
    unsortedChildren: [
      make('card-content', {
        contentType: 'short-input',
        text: 'Can you answer my parent question?'
      }),
      make('card-content', {
        contentType: 'repeat',
        min: 1,
        itemName: 'inner thing',
        repetitions: [],
        unsortedChildren: [
          make('card-content', {
            contentType: 'short-input',
            text: 'Can you answer my child question?'
          })
        ]
      })]
  });

  this.set('content', content);
  this.set('disabled', false);
  this.set('owner', make('custom-card-task'));
  this.set('repetition', null);
  this.render(template);

  return wait().then(() => {
    assert.elementNotFound('.card-content-repeat input', 'no repeater is initially built');
    this.$('.add-repetition').click();

    return wait().then(() => {
      // ensure that parent repetition was added and since child repeatition had a min of 1,
      // check that it was automatically added
      assert.nElementsFound('.card-content-repeat input', 2, 'found inputs from both repeaters');
      assert.textPresent('.card-content-repeat', 'parent question', 'found parent question');
      assert.textPresent('.card-content-repeat', 'child question', 'found child question');
    });
  });
});

