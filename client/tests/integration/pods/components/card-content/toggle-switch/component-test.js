import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';

moduleForComponent(
  'card-content/toggle-switch',
  'Integration | Component | card content | toggle switch',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.set('actionStub', function() {});
      this.set('content', Ember.Object.create({ ident: 'test' }));
      this.set('answer', Ember.Object.create({ value: null }));
    }
  }
);

let template = hbs`{{card-content/toggle-switch
content=content
labelText=labelText
disabled=disabled
answer=answer
valueChanged=(action actionStub)
}}`;

test(`it displays the label`, function(assert) {
  this.set('labelText', 'my label' );
  this.render(template);
  assert.textPresent('.checked-label-text', 'my label');
});

test(`it renders a hidden checkbox`, function(assert) {
  this.render(template);
  assert.elementFound('.card-content-toggle-switch input[type=checkbox]');
});

test(`it disables the input if disabled=true`, function(assert) {
  this.set('disabled', true);
  this.render(template);
  assert.elementFound('.card-content-toggle-switch input[type=checkbox]:disabled');
});

test(`it is checked if the answer is truthy`, function(assert) {
  this.set('answer', Ember.Object.create({ value: true }));
  this.render(template);
  assert.elementFound('.card-content-toggle-switch input[type=checkbox]:checked');
});

test(`it sends 'valueChanged' on change`, function(assert) {
  assert.expect(1);
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, true, 'it calls the action with the new value');
  });
  this.render(template);
  this.$('.card-content-toggle-switch input').click();
});
