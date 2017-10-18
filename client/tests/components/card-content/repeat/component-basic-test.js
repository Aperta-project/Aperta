import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
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

let setValue = ($input, newVal) => {
  return $input.val(newVal).trigger('input').trigger('blur');
};


test(`it builds the minimum number of repetitions that were specified`, function(assert) {
  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, responseText: '{}'});

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

test(`it saves an answer for the repetition`, function(assert) {
  let newRepetitionId = 99;

  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, responseText: { repetition: { id: newRepetitionId }}});
  $.mockjax({url: '/api/answers', type: 'POST', status: 201, responseText: { answer: { id: 219, repetition_id: newRepetitionId }}});

  let content = FactoryGuy.make('card-content', {
    contentType: 'repeat',
    min: 1,
    itemName: 'thing',
    repetitions: [],
    unsortedChildren: [
      FactoryGuy.make('card-content', {
        contentType: 'short-input',
        text: 'Can you answer my simple question?'
      })
    ]
  });

  let store = this.container.lookup('service:store');

  this.set('content', content);
  this.set('disabled', false);
  this.set('owner', Ember.Object.create());
  this.set('repetition', null);
  this.render(template);

  return wait().then(() => {
    assert.nElementsFound('.card-content-repeat input', 1, 'found input');
    assert.equal(store.peekAll('answer').get('firstObject.value'), undefined, 'the initial answer is built but left blank');
    setValue(this.$('.card-content-repeat input'), 'best answer');
    return wait().then(() => {
      let answer = store.peekAll('answer').get('firstObject');
      assert.equal(answer.get('value'), 'best answer', 'the answer now has a value');
      assert.equal(answer.get('repetition.id'), newRepetitionId, 'the answer belongs to the repetition');
    });
  });
});

test(`it builds no repetitions when no minimum number of repetitions are specified`, function(assert) {
  let content = FactoryGuy.make('card-content', {
    contentType: 'repeat',
    min: null,
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
    assert.elementNotFound('.card-content-repeat input', 'did not find input');
  });
});


test(`it does not allow more repetitions to be created when max number is reached`, function(assert) {
  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, responseText: '{}'});

  let content = FactoryGuy.make('card-content', {
    contentType: 'repeat',
    min: null,
    max: 1,
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
  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, responseText: '{}'});

  let content = FactoryGuy.make('card-content', {
    contentType: 'repeat',
    min: 1,
    max: null,
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
    // ensure delete button is not enabled
    assert.elementNotFound('.remove-repetition', 'remove button is not found');
    this.$('.add-repetition').click();

    return wait().then(() => {
      assert.nElementsFound('.remove-repetition', 2, 'remove buttons found');
    });
  });
});


test(`it adds a repetition between two other repetitions`, function(assert) {
  let store = this.container.lookup('service:store');

  let repetitionIdSeed = 110;
  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, response: function() {
    this.responseText = {
      repetition: { id: repetitionIdSeed++ },
    };
  }});

  let content = FactoryGuy.make('card-content', {
    contentType: 'repeat',
    min: 2,
    max: null,
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
    assert.nElementsFound('.repeated-block', 2, 'found initial repetitions');
    this.$('.add-repetition:first').click()

    return wait().then(() => {
      assert.nElementsFound('.repeated-block', 3, 'new repetition was added');
      assert.equal(store.peekRecord('repetition', 110).get('position'), 0, 'the initial repetition created should be first in the list');
      assert.equal(store.peekRecord('repetition', 112).get('position'), 1, 'the newly created repetition should be second in the list');
    });
  });
});
