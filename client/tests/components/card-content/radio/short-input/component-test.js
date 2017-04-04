import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'card-content/short-input',
  'Integration | Component | card content | short input',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.set('actionStub', function() {});
    }
  }
);

let template = hbs`{{card-content/short-input
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
test(`it displays unescaped html text`, function(assert) {
  this.set('content', {text: '<b class="foo">Foo</b>'});
  this.render(template);
  assert.elementFound('b.foo');
});
test(`it disables the input if disabled=true`, function(assert) {
  this.set('disabled', true);
  this.render(template);
  assert.elementFound('input[disabled]');
});
test(`it shows a placeholder from content.placeholder`, function(assert) {
  this.set('content', {placeholder: 'Foo'});
  this.render(template);
  assert.elementFound('input[placeholder=Foo]');
});
test(`it displays the value from answer.value`, function(assert) {
  this.set('answer', {value: 'Bar'});
  this.render(template);
  assert.equal(this.$('input').val(), 'Bar');
});
test(`it sends 'valueChanged' on change`, function(assert) {
  assert.expect(1);
  this.set('answer', {value: 'Old'});
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, 'New', 'it calls the action with the new value');
  });
  this.render(template);
  this.$('input').val('New').trigger('change');
});
test(`it sends 'valueChanged' on input`, function(assert) {
  assert.expect(1);
  this.set('answer', {value: 'Old'});
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, 'New', 'it calls the action with the new value');
  });
  this.render(template);
  this.$('input').val('New').trigger('input');
});
