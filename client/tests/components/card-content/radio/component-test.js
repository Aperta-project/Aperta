import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'card-content/radio',
  'Integration | Component | card content | radio',
  {
    integration: true,
    beforeEach() {
      this.set('actionStub', function() {});
      this.defaultContent = {
        text: `<b class='foo'>Foo</b>`,
        possibleValues: [{ label: 'Choice 1', value: 1 }, { label: '<b>Choice</b> 2', value: 2}]
      };
    }
  }
);

let template = hbs`
{{card-content/radio
  answer=answer
  content=content
  disabled=disabled
  valueChanged=(action actionStub)}}`;

test(`it renders a radio button for each of the possibleValues, allowing html`, function(assert) {
  this.set('content', this.defaultContent);
  this.render(template);
  assert.textPresent('.option', 'Choice 1');
  assert.textPresent('.option', 'Choice 2');
  assert.elementFound('.option b', 'The bold tag is rendered properly');
});
test(`it displays unescaped html text from the content`, function(assert) {
  this.set('content', this.defaultContent);
  this.render(template);
  assert.elementFound('b.foo');
  assert.textPresent('b', 'Foo');
});
test(`it disables the inputs if disabled=true`, function(assert) {
  this.set('disabled', true);
  this.set('content', this.defaultContent);
  this.render(template);
  assert.equal(this.$('input[disabled]').length, 2);
});
test(`it checks the button corresponding to the answer's value`, function(assert) {
  this.set('answer', { value: 2});
  this.set('content', this.defaultContent);
  this.render(template);
  assert.equal(this.$('input:checked').val(), 2);
});
test(`it checks the button corresponding to the answer's value with different datatypes`, function(assert) {
  this.set('answer', { value: '2'});
  this.set('content', this.defaultContent);
  this.render(template);
  assert.equal(this.$('input:checked').val(), 2);
});
test(`no buttons are checked if the answer's value is blank/null`, function(assert) {
  this.set('answer', { value: null});
  this.set('content', this.defaultContent);
  this.render(template);
  assert.equal(this.$('input:checked').length, 0);
});
test(`it sends 'valueChanged' on change`, function(assert) {
  assert.expect(1);
  this.set('answer', { value: null});
  this.set('content', this.defaultContent);
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, 2, 'it calls the action with the new value');
  });
  this.render(template);
  this.$('input:last').val('New').trigger('change');
});
