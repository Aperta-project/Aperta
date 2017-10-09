import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import sinon from 'sinon';
import Ember from 'ember';

moduleForComponent(
  'card-content/display-with-value',
  'Integration | Component | card content | display with value',
  {
    integration: true,
    beforeEach: function() {
      manualSetup(this.container);
    }
  }
);

let template = hbs`
{{card-content/display-with-value
  class="display-test"
  owner="this can be anything"
  disabled=disabled
  tagName="div"
  content=content}}`;

let fakeTextContent = Ember.Object.extend({
  contentType: 'text',
  text: 'Child 1' ,
  answerForOwner() {
    return {value: 'foo'};
  }
});


test(
  `when disabled, it marks its children as disabled`,
  function(assert) {
    let content = fakeTextContent.create({
      visibleWithParentAnswer: 'foo',
      parent: {
        answerForOwner() {
          return {value: 'foo'};
        }
      },
      children: [
        FactoryGuy.make('card-content', 'shortInput', { text: 'Child 1' })
      ]
    });
    this.set('content', content);
    this.set('disabled', true);
    this.render(template);
    assert.elementFound('.card-content-short-input input:disabled', 'found disabled short input');
  }
);

/*
 * Note that both of these tests are stubbing the `answerForOwner` function,
 * so passing in an actual `owner` isn't needed.  The test does need to fake the
 * shape of `content.parent`, though
 */
test(
  `when the parent's answer value is the same as visibleWithParentAnswer, it renders its children`,
  function(assert) {
    let content = fakeTextContent.create({
      visibleWithParentAnswer: 'foo',
      parent: {
        answerForOwner() {
          return {value: 'foo'};
        }
      },
      children: [
        fakeTextContent.create({text: 'Child 1'}),
        fakeTextContent.create({text: 'Child 2'})
      ]
    });
    this.set('content', content);
    this.render(template);
    assert.textPresent('.display-test', 'Child 1');
    assert.textPresent('.display-test', 'Child 2');
  }
);

test(
  `it converts the parent's answer to a string for the purposes of the check since
   visibleWithParentAnswer is always a string`,
  function(assert) {
    let content = fakeTextContent.create({
      visibleWithParentAnswer: '1',
      parent: {
        answerForOwner() {
          return {value: 1};
        }
      },
      children: [
        fakeTextContent.create({text: 'Child 1'}),
        fakeTextContent.create({text: 'Child 2'})
      ]
    });
    this.set('content', content);
    this.render(template);
    assert.textPresent('.display-test', 'Child 1');
    assert.textPresent('.display-test', 'Child 2');
  }
);
test(
  `it allows visibleWithParentAnswer to be an empty string`,
  function(assert) {
    let content = fakeTextContent.create({
      visibleWithParentAnswer: '',
      parent: {
        answerForOwner() {
          return {value: ''};
        }
      },
      children: [
        fakeTextContent.create({text: 'Child 1'}),
        fakeTextContent.create({text: 'Child 2'})
      ]
    });
    this.set('content', content);
    this.render(template);
    assert.textPresent('.display-test', 'Child 1');
    assert.textPresent('.display-test', 'Child 2');
  }
);
test(
  `when the parent's answer value is different than visibleWithParentAnswer, it renders nothing`,
  function(assert) {
    let content = fakeTextContent.create({
      visibleWithParentAnswer: 'foo',
      parent: {
        answerForOwner() {
          return {value: 'bar'};
        }
      },
      children: [
        fakeTextContent.create({text: 'Child 1'}),
        fakeTextContent.create({text: 'Child 2'})
      ]
    });
    this.set('content', content);
    this.render(template);
    assert.textNotPresent('.display-test', 'Child 1');
    assert.textNotPresent('.display-test', 'Child 2');
  });
test(
  `it returns false if the parent answer value is null`,
  function(assert) {
    let content = fakeTextContent.create({
      visibleWithParentAnswer: '1',
      parent: {
        answerForOwner() {
          return {value: null};
        }
      },
      children: [
        fakeTextContent.create({text: 'Child 1'}),
      ]
    });
    this.set('content', content);
    this.render(template);
    assert.textNotPresent('.display-test', 'Child 1');
  }
);
test(
  `it returns false if the parent answer value is undefined`,
  function(assert) {
    let content = fakeTextContent.create({
      visibleWithParentAnswer: '1',
      parent: {
        answerForOwner() {
          return {};
        }
      },
      children: [
        fakeTextContent.create({text: 'Child 1'}),
      ]
    });
    this.set('content', content);
    this.render(template);
    assert.textNotPresent('.display-test', 'Child 1');
  }
);

test(
  `destroy child answers when children are hidden`,
  function(assert) {
    let template = hbs`
    {{card-content/display-with-value
      class="removing-answers-test"
      owner=owner
      disabled=disabled
      tagName="div"
      content=content}}`;

    let owner = FactoryGuy.make('custom-card-task');

    let contentRoot = owner.get('cardVersion.contentRoot');
    let displayWithValueContent = FactoryGuy.make('card-content', { visibleWithParentAnswer: 'banana' });
    let childContent = FactoryGuy.make('card-content', { text: 'what color is the sky?' });

    Ember.run(() => { // setting unsorted children needs a run loop
      contentRoot.set('unsortedChildren', [displayWithValueContent]);
      displayWithValueContent.set('unsortedChildren', [childContent]);

      let parentAnswer = FactoryGuy.make('answer', { owner: owner, cardContent: contentRoot, value: 'banana' });
      let childAnswer = FactoryGuy.make('answer', { owner: owner, cardContent: childContent, value: 'THE CORRECT ANSWER' });
      const destroyRecord = sinon.spy();
      childAnswer.set('destroyRecord', destroyRecord);

      this.set('owner', owner);
      this.set('content', displayWithValueContent);
      this.render(template);
      assert.textPresent('.removing-answers-test', 'what color is the sky?');
      parentAnswer.set('value', 'pineapple');
      assert.textNotPresent('.removing-answers-test', 'actual text');
      assert.ok(destroyRecord.called, 'destroyRecord was called');
    });
  }
);
