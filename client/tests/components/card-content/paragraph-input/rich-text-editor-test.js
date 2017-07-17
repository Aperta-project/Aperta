import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'card-content/paragraph-input',
  'Integration | Component | card content | rich text input',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.set('actionStub', function() {});
    }
  }
);

let template = hbs`{{
  card-content/paragraph-input
  ident='test-editor'
  answer=answer
  content=content
  disabled=disabled
  onContentsChanged=(action actionStub)
}}`;

test(`setting the value-type to text renders a textarea`, function(assert) {
  this.set('content', Ember.Object.create({valueType: 'text', text: 'Some Text'}));
  this.render(template);
  assert.equal(0, window.tinymce.editors.length);
});

test(`setting the value-type to html renders the rich-text editor`, function(assert) {
  this.set('content', Ember.Object.create({valueType: 'html', text: 'Some Text'}));
  this.render(template);
  assert.equal(1, window.tinymce.editors.length);
});
