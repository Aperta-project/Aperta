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

let template = hbs`{{card-content/paragraph-input
answer=answer
content=content
disabled=disabled
valueChanged=(action actionStub)
}}`;

test(`it displays the text from content.text in a <label>`, function(assert) {
  this.set('content', Ember.Object.create({text: 'Foo'}));
  this.render(template);
  assert.textPresent('.content-text', 'Foo');
});
