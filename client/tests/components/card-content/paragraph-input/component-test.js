import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import {getRichText, setRichText} from 'tahi/tests/helpers/rich-text-editor-helpers';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'card-content/paragraph-input',
  'Integration | Component | card content | paragraph input',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.set('actionStub', function() {});
    }
  }
);

let template = hbs`{{card-content/paragraph-input
answer=answer
content=content
disabled=disabled
valueChanged=(action actionStub)
}}`;
test(`it displays the text from content.text in a <label>`, function(assert) {
  this.set('content', {text: 'Foo'});
  this.render(template);
  assert.textPresent('.content-text', 'Foo');
});
test(`it displays unescaped html text in the label`, function(assert) {
  this.set('content', {text: '<b class="foo">Foo</b>'});
  this.render(template);
  assert.elementFound('b.foo');
});
test(`it only displays the answer as text disabled=true`, function(assert) {
  this.set('disabled', true);
  this.render(template);
  assert.elementFound('.read-only');
});
test(`it displays the rich text (html formatted) value from answer.value`, function(assert) {
  this.set('content', {ident: 'rich-text-editor-widget'});
  this.set('answer', {value: 'an existing answer'});
  this.render(template);
  assert.equal(getRichText('rich-text-editor-widget'), '<p>an existing answer</p>');
});
test(`it sends 'valueChanged' on keyup`, function(assert) {
  assert.expect(1);
  this.set('content', {ident: 'rich-text-editor-widget'});
  this.set('answer', {value: 'Old'});
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, '<p>a new value</p>', 'it calls the action with the new value');
  });
  this.render(template);
  setRichText('rich-text-editor-widget', 'a new value');
});
test('it displays error messages if present', function(assert){
  let errorsArr = ['Oh Noes', 'You fool!'];
  this.set('answer', Ember.Object.create({readyIssuesArray: errorsArr}));
  this.render(template);
  assert.equal(this.$('.validation-error').length, 2, 'Two errors are present');
  assert.equal(this.$('.validation-error').eq(0).text(), errorsArr[0], 'First error text matches');
  assert.equal(this.$('.validation-error').eq(1).text(), errorsArr[1], 'Second error text matches');
  let text = 'Error class present on parent element';
  assert.ok(this.$('.card-content-paragraph-input').hasClass('has-error'), text);
});
