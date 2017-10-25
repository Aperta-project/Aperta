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

      this.labelAndText = Ember.Object.create({ text: '<b class="foo">Foo</b>', label: 'some label' });
      this.labelOnly = Ember.Object.create({ label: 'some label' });
      this.textOnly = Ember.Object.create({ text: '<b class="foo">Foo</b>' });
    }
  }
);

let template = hbs`{{card-content/check-box
answer=answer
content=content
disabled=disabled
valueChanged=(action actionStub)
}}`;

test(`it displays content.text as unescaped html in a <p> if a label is also present`, function(
  assert
) {
  this.set(
    'content',
    this.labelAndText
  );

  this.render(template);
  assert.elementFound('.content-text b.foo');
});

test(`it uses the content.text as the label if a label is not present`, function(
  assert
) {
  this.set('content', this.textOnly);

  this.render(template);
  assert.elementFound('label b.foo');
});

test(`it uses the content.text as the label if a label is not present`, function(
  assert
) {
  this.set('content', this.textOnly);

  this.render(template);
  assert.elementFound('label b.foo');
  assert.elementNotFound('.content-text', 'does not render an empty .content-text div when no content label');
});

test(`it displays content.label as unescaped html`, function(assert) {
  this.set(
    'content',
    Ember.Object.create({ label: '<b class="foo">Foo</b>' })
  );
  this.render(template);
  assert.elementFound('label b.foo');
  assert.elementNotFound('.content-text', 'does not render an empty .content-text div when no content text');
});

test(`the label is for the input`, function(assert) {
  this.set('content', this.labelOnly);
  this.render(template);
  assert.ok(
    this.$('input').attr('name'),
    'the name is set automatically if no ident'
  );
  assert.ok(
    this.$('input').attr('id'),
    'the id is set automatically if no ident'
  );
  assert.ok(
    this.$('label').attr('for'),
    'the for is set automatically if no ident'
  );
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
  assert.elementFound('.card-content-check-box input:checked');
});

test(`it sends 'valueChanged' on change`, function(assert) {
  assert.expect(1);
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, true, 'it calls the action with the new value');
  });
  this.render(template);
  this.$('input').click();
});

test(`it displays an asterisks if 'content.isRequred set to true`, function(
  assert
) {
  this.set(
    'content',
    Ember.Object.create({
      ident: 'test',
      text: 'Test check-box',
      isRequired: true,
      label: 'some label'
    })
  );
  this.render(template);
  assert.elementFound('.content-text .required-field', 'shows the required asterix under .content-text when both content.label and content.text are present');
  assert.elementNotFound('label .required-field');
  this.set('content.text', null);
  assert.elementFound('label .required-field', 'shows the required asterix under the label if no content.text');
  this.set('content.text', 'here');
  this.set('content.label', null);
  assert.elementFound('label .required-field', 'shows the required asterix under the label if no content.label');
});

test(`it does not display an asterisks if 'content.isRequred set to false`, function(
  assert
) {
  this.set(
    'content',
    Ember.Object.create({
      ident: 'test',
      text: 'Test check-box',
      isRequired: false,
      label: 'some label'
    })
  );
  this.render(template);
  assert.elementNotFound('.required-field');
});
