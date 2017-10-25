import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import { manualSetup, make } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import wait from 'ember-test-helpers/wait';

moduleForComponent(
  'card-content/repeat',
  'Integration | Component | card content | repeat (basic)',
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

test(`it builds the minimum number of repetitions that were specified`, function(assert) {
  let repetitionIdSeed = 110;
  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, response: function() {
    this.responseText = {
      repetition: { id: repetitionIdSeed++ },
    };
  }});

  let content = make('card-content', {
    contentType: 'repeat',
    min: 2,
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
  this.set('owner', Ember.Object.create());
  this.set('repetition', null);
  this.render(template);

  return wait().then(() => {
    assert.nElementsFound('.card-content-repeat input', 2, 'found input');
  });
});

test(`it builds no repetitions when no minimum number of repetitions are specified`, function(assert) {
  let content = make('card-content', {
    contentType: 'repeat',
    min: null,
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
  this.set('owner', Ember.Object.create());
  this.set('repetition', null);
  this.render(template);

  return wait().then(() => {
    assert.elementNotFound('.card-content-repeat input', 'did not find input');
  });
});


test(`it does not allow more repetitions to be created when max number is reached`, function(assert) {
  let repetitionIdSeed = 110;
  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, response: function() {
    this.responseText = {
      repetition: { id: repetitionIdSeed++ },
    };
  }});

  let content = make('card-content', {
    contentType: 'repeat',
    min: null,
    max: 1,
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
  this.set('owner', Ember.Object.create());
  this.set('repetition', null);
  this.render(template);

  // ensure add button is enabled and can be clicked
  assert.elementNotFound('.card-content-repeat input', 'did not find input');
  assert.elementFound('.add-repetition:not(.disabled)', 'found enabled add button');
  this.$('.add-repetition').click();

  return wait().then(() => {
    // ensure that repetition was added and add button is now disabled
    // since max number of repetitions was reached
    assert.nElementsFound('.card-content-repeat input', 1, 'found input');
    assert.elementFound('.add-repetition.disabled', 'found disabled add button');
  });
});

test(`it only allows repetitions to be deleted when min number is reached`, function(assert) {
  let repetitionIdSeed = 110;
  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, response: function() {
    this.responseText = {
      repetition: { id: repetitionIdSeed++ },
    };
  }});


  let content = make('card-content', {
    contentType: 'repeat',
    min: 1,
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
  this.set('owner', Ember.Object.create());
  this.set('repetition', null);
  this.render(template);


  return wait().then(() => {
    // ensure delete button is not enabled
    assert.elementNotFound('.remove-repetition', 'remove button is not found');
    this.$('.add-repetition').click();

    return wait().then(() => {
      assert.nElementsFound('.remove-repetition', 2, 'remove buttons found');
    });
  });
});

