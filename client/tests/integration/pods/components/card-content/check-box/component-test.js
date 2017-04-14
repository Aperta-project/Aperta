import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';

moduleForComponent(
  'card-content/check-box',
  'Integration | Component | card content | check box',
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

let template = hbs`{{card-content/check-box
answer=answer
content=content
disabled=disabled
valueChanged=(action actionStub)
}}`;

test(`it displays content.text as unescaped html in a <p>`, function(assert) {
  this.set('content', Ember.Object.create({ text: '<b class="foo">Foo</b>' }));

  this.render(template);
  assert.elementFound('.content-text b.foo');
});

test(`it displays content.label as unescaped html`, function(assert) {
  this.set('content', Ember.Object.create({ label: '<b class="foo">Foo</b>' }));
  this.render(template);
  assert.elementFound('label b.foo');
});

test(`the label is for the input`, function(assert) {
  this.set('content', Ember.Object.create({ label: 'test' }));
  this.render(template);
  assert.ok(this.$('input').attr('name'), 'the name is set automatically if no ident');
  assert.ok(this.$('input').attr('id'), 'the id is set automatically if no ident');
  assert.ok(this.$('label').attr('for'), 'the for is set automatically if no ident');
  assert.equal(this.$('label').attr('for'), this.$('input').attr('name'));
});

test('includes the ident in the name and id if present', function(assert) {
  this.set('content', Ember.Object.create({ ident: 'test' }));
  this.render(template);
  assert.equal(this.$('input').attr('name'), 'check-box-test');
  assert.equal(this.$('input').attr('id'), 'check-box-test');
});
test(`it disables the input if disabled=true`, function(assert) {
  this.set('disabled', true);
  this.render(template);
  assert.elementFound('input[disabled]');
});

test(`it is checked if the answer is truthy`, function(assert) {
  this.set('answer', Ember.Object.create({ value: true }));
  this.render(template);
  assert.elementFound('input[checked]');
});

test(`it sends 'valueChanged' on change`, function(assert) {
  assert.expect(1);
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, true, 'it calls the action with the new value');
  });
  this.render(template);
  this.$('input').click();
});
