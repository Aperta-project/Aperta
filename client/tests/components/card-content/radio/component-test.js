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
        valueType: 'text',
        possibleValues: [{ label: 'Choice 1', value: 1 }, { label: '<b>Choice</b> 2', value: 2}]
      };

      this.radioBooleanContent = {
        text: `<b class='bar'>Bar</b>`,
        valueType: 'boolean'
      };

      this.radioWithoutText = {
        valueType: 'boolean'
      };

      this.radioBooleanLabeledContent = {
        text: `<b class='foo'>Foo</b>`,
        valueType: 'text',
        possibleValues: [{ label: 'Why Yes', value: 'true' }, { label: 'Oh No', value: 'false'}]
      };

      this.radioBooleanLabeledRequiredFieldContent = {
        text: `<b class='foo'>Foo</b>`,
        valueType: 'text',
        requiredField: 'true',
        possibleValues: [{ label: 'Why Yes', value: 'true' }, { label: 'Oh No', value: 'false'}]
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
  let labels = this.$('.card-form-label');
  assert.textPresent(labels[0], 'Choice 1');
  assert.textPresent(labels[1], 'Choice 2');
  assert.elementFound('.card-form-label b', 'The bold tag is rendered properly');
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

test(`it renders a radio button for Yes and No when value type is boolean`, function(assert) {
  this.set('content', this.radioBooleanContent);
  this.render(template);
  assert.textPresent('.card-form-element', 'Yes');
  assert.textPresent('.card-form-element', 'No');
});

test(`it renders no text if absent`, function(assert) {
  this.set('content', this.radioWithoutText);
  this.render(template);
  assert.elementNotFound('.card-form-text');
});

test(`it renders text when supplied`, function(assert) {
  this.set('content', this.radioBooleanContent);
  this.render(template);
  assert.elementFound('.card-form-text');
});

test(`it renders the supplied true and false labels when value type is boolean`, function(assert) {
  this.set('content', this.radioBooleanLabeledContent);
  this.render(template);
  assert.textPresent('.card-form-label', 'Why Yes');
  assert.textPresent('.card-form-label', 'Oh No');
});

test(`it displays an error message when a field is marked required and not answered`, function(assert) {
  this.set('answer', { ready: false, readyIssuesArray: ['This field is required.'], hideErrors: false});
  this.set('content', this.radioBooleanLabeledRequiredFieldContent);
  this.render(template);
  let errors = this.$('.error-message');
  assert.textPresent(errors[0], 'This field is required.');
});

test(`it does not display an error message when a field is marked required and hide errors is true`, function(assert) {
  this.set('answer', { ready: false, readyIssuesArray: ['This field is required.'], hideErrors: true});
  this.set('content', this.radioBooleanLabeledRequiredFieldContent);
  this.render(template);
  let errors = this.$('.error-message');
  assert.textPresent(errors[0], '');
});
