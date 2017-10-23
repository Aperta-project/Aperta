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
  this.set('owner', FactoryGuy.make('custom-card-task'));
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
  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, responseText: '{}'});

  let content = FactoryGuy.make('card-content', {
    contentType: 'repeat',
    min: 0,
    itemName: 'outer thing',
    repetitions: [],
    unsortedChildren: [
      FactoryGuy.make('card-content', {
        contentType: 'short-input',
        text: 'Can you answer my parent question?'
      }),
      FactoryGuy.make('card-content', {
        contentType: 'repeat',
        min: 1,
        itemName: 'inner thing',
        repetitions: [],
        unsortedChildren: [
          FactoryGuy.make('card-content', {
            contentType: 'short-input',
            text: 'Can you answer my child question?'
          })
        ]
      })]
  });

  this.set('content', content);
  this.set('disabled', false);
  this.set('owner', FactoryGuy.make('custom-card-task'));
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

test(`it destroys answers within a repetition if hidden`, function(assert) {
  let newRepetitionId = 99;
  let newAnswerId = 800;

  $.mockjax({url: '/api/repetitions', type: 'POST', status: 201, response: function() {
    this.responseText = {
      repetition: { id: newRepetitionId++ }
    };
  }});
  $.mockjax({url: '/api/answers', type: 'POST', status: 201, response: function() {
    this.responseText = {
      answer: { id: newAnswerId++ }
    };
  }});
  $.mockjax({url: '/api/answers/*', type: 'DELETE', status: 204});
  $.mockjax({url: '/api/repetitions/*', type: 'DELETE', status: 204});
  $.mockjax({url: '/api/answers/*', type: 'PUT', status: 204});

  // A somewhat complicated, nested example:
  //
  // - repeater
  //   - radio
  //     - display with value 'true'
  //       - short-input
  //       - repeater
  //         - short-input
  //     - display with value 'false'
  //       - short-input
  //
  let content = FactoryGuy.make('card-content', {
    id: 1001,
    contentType: 'repeat',
    min: 2,
    itemName: 'thing',
    valueType: null,
    unsortedChildren: [
      FactoryGuy.make('card-content', {
        id: 1002,
        contentType: 'radio',
        valueType: 'boolean',
        defaultAnswerValue: 'true',
        text: 'Please pick one',
        unsortedChildren: [
          FactoryGuy.make('card-content', {
            id: 1003,
            contentType: 'display-with-value',
            valueType: null,
            visibleWithParentAnswer: 'true',
            unsortedChildren: [
              FactoryGuy.make('card-content', {
                id: 1004,
                contentType: 'short-input',
                valueType: 'text',
                text: 'You picked Yes in the radio',
              }),
              FactoryGuy.make('card-content', {
                id: 1005,
                contentType: 'repeat',
                min: 1,
                itemName: 'inner thing',
                valueType: null,
                unsortedChildren: [
                  FactoryGuy.make('card-content', {
                    id: 1006,
                    contentType: 'short-input',
                    valueType: 'text',
                    text: 'Name your inner thing'
                  })
                ]
              })
            ]
          }),
          FactoryGuy.make('card-content', {
            id: 1007,
            contentType: 'display-with-value',
            valueType: null,
            visibleWithParentAnswer: 'false',
            unsortedChildren: [
              FactoryGuy.make('card-content', {
                id: 1008,
                contentType: 'short-input',
                valueType: 'text',
                text: 'Name your inner thing'
              })
            ]
          }),
        ]
      })
    ]
  });

  let store = this.container.lookup('service:store');

  this.set('content', content);
  this.set('disabled', false);
  this.set('owner', FactoryGuy.make('custom-card-task'));
  this.set('repetition', null);
  this.render(template);

  let getAnswer = function(answers, repetitionId, cardContentId) {
    return answers.filterBy('repetition.id', repetitionId).findBy('cardContent.id', cardContentId);
  };

  return wait().then(() => {
    let $textBoxes = this.$('.card-content-repeat input[type="text"]');
    // make sure all text input elements exist
    assert.nElementsFound($textBoxes, 4, 'found all textbox inputs were created');

    let repetitions = store.peekAll('repetition');
    assert.equal(repetitions.get('length'), 4);
    let firstOuterRep = repetitions.filterBy('cardContent.id', '1001').get('firstObject');
    let secondOuterRep = repetitions.filterBy('cardContent.id', '1001').get('lastObject');
    let firstInnerRep = repetitions.filterBy('cardContent.id', '1005').get('firstObject');
    let secondInnerRep = repetitions.filterBy('cardContent.id', '1005').get('lastObject');
    assert.ok(firstOuterRep.get('id'));
    assert.ok(secondOuterRep.get('id'));
    assert.ok(firstInnerRep.get('id'));
    assert.ok(secondInnerRep.get('id'));

    // answer all the text box questions
    setValue($textBoxes.eq(0), 'aaa');
    setValue($textBoxes.eq(1), 'bbb');
    setValue($textBoxes.eq(2), 'ccc');
    setValue($textBoxes.eq(3), 'ddd');

    // verify that all answers are associated with the correct repetition
    return wait().then(() => {
      let answers = store.peekAll('answer').sortBy('id');
      let answerA = getAnswer(answers, firstOuterRep.get('id'), '1004');
      let answerB = getAnswer(answers, firstInnerRep.get('id'), '1006');
      let answerC = getAnswer(answers, secondOuterRep.get('id'), '1004');
      let answerD = getAnswer(answers, secondInnerRep.get('id'), '1006');
      assert.equal(answerA.get('value'), 'aaa');
      assert.equal(answerB.get('value'), 'bbb');
      assert.equal(answerC.get('value'), 'ccc');
      assert.equal(answerD.get('value'), 'ddd');

      // verify that original answers + inner repetition are destroyed when flipping the radio button
      let $firstRadio = this.$('.card-content-repeat input[type="radio"][value="false"]:first');
      $firstRadio.click();

      return wait().then(() => {
        // the inner repetition & its answers should be deleted
        assert.ok(firstInnerRep.get('isDeleted'));
        assert.ok(answerA.get('isDeleted'));
        assert.ok(answerB.get('isDeleted'));

        // none of the other stuff should be
        assert.notOk(firstOuterRep.get('isDeleted'));
        assert.notOk(secondOuterRep.get('isDeleted'));
        assert.notOk(secondInnerRep.get('isDeleted'));
        assert.notOk(answerC.get('isDeleted'));
        assert.notOk(answerD.get('isDeleted'));
      });
    });
  });
});
