import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent(
  'card-content/display-with-value',
  'Integration | Component | card content | display with value',
  {
    integration: true
  }
);

let template = hbs`
{{card-content/display-with-value
  class="display-test"
  owner="this can be anything"
  tagName="div"
  content=content}}`;

let fakeContent = Ember.Object.extend({
  contentType: 'text',
  text: 'Child 1' ,
  answerForOwner() {
    return {value: 'foo'};
  }
});


/*
 * Note that both of these tests are stubbing the `answerForOwner` function,
 * so passing in an actual `owner` isn't needed.  The test does need to fake the
 * shape of `content.parent`, though
 */
test(
  `when the parent's answer value is the same as visibleWithParentAnswer, it renders its children`,
  function(assert) {
    let content = fakeContent.create({
      visibleWithParentAnswer: 'foo',
      parent: {
        answerForOwner() {
          return {value: 'foo'};
        }
      },
      children: [
        fakeContent.create({text: 'Child 1'}),
        fakeContent.create({text: 'Child 2'})
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
    let content = fakeContent.create({
      visibleWithParentAnswer: '1',
      parent: {
        answerForOwner() {
          return {value: 1};
        }
      },
      children: [
        fakeContent.create({text: 'Child 1'}),
        fakeContent.create({text: 'Child 2'})
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
    let content = fakeContent.create({
      visibleWithParentAnswer: 'foo',
      parent: {
        answerForOwner() {
          return {value: 'bar'};
        }
      },
      children: [
        fakeContent.create({text: 'Child 1'}),
        fakeContent.create({text: 'Child 2'})
      ]
    });
    this.set('content', content);
    this.render(template);
    assert.textNotPresent('.display-test', 'Child 1');
    assert.textNotPresent('.display-test', 'Child 2');
  });
