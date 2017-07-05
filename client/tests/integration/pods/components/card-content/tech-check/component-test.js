import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';

moduleForComponent(
  'card-content/tech-check',
  'Integration | Component | card content | tech check',
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

let template = hbs`{{card-content/tech-check
content=content
disabled=disabled
answer=answer
valueChanged=(action actionStub)
}}`;

test(`it displays the 'Pass' label`, function(assert) {
  this.set('labelText', 'my label' );
  this.render(template);
  assert.textPresent('.checked-label-text', 'Pass');
});

test(`it displays content.text as unescaped html`, function(assert) {
  this.set('content', Ember.Object.create({ text: '<b class="foo">Foo</b>' }));
  this.render(template);
  assert.elementFound('.content-text b.foo');
});

test(`the label is for the input`, function(assert) {
  this.set('content', Ember.Object.create({ label: 'test' }));
  this.render(template);
  assert.ok(this.$('input').attr('name'), 'the name is set automatically if no ident');
  assert.ok(this.$('input').attr('id'), 'the id is set automatically if no ident');
  assert.ok(this.$('label').attr('for'), 'the for is set automatically if no ident');
  assert.equal(this.$('label').attr('for'), this.$('input').attr('name'));
});

test(`it sends 'valueChanged' on change`, function(assert) {
  assert.expect(1);
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, true, 'it calls the action with the new value');
  });
  this.render(template);
  this.$('.card-content-toggle-switch input').click();
});
