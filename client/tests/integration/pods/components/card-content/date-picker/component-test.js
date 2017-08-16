import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';

moduleForComponent(
  'card-content/date-picker',
  'Integration | Component | card content | date picker',
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

let template = hbs`{{card-content/date-picker
answer=answer
content=content
valueChanged=(action actionStub)
}}`;

test(`it displays content.text as unescaped html in a <p>`, function(assert) {
  this.set('content', Ember.Object.create({ text: '<b class="foo">Foo</b>' }));

  this.render(template);
  assert.elementFound('.card-content-date-picker b.foo');
});

test(`it renders a date picker with a title`, function(assert) {
  this.set('content', Ember.Object.create({ text: 'Title' }));

  this.render(template);
  assert.textPresent('p.picker-title', 'Title');
  assert.elementFound('input.datepicker');
});

test('includes the ident in the name and id if present', function(assert) {
  this.set('content', Ember.Object.create({ ident: 'test' }));
  this.render(template);
  assert.equal(this.$('input').attr('name'), 'date-picker-test');
});

test('it displays an asterisks if content.isRequred set to true', function(assert) {
  this.set('content', Ember.Object.create({ ident: 'test' , text: 'Test data-picker', isRequired: true}));
  this.render(template);
  assert.equal(this.$('p span.required-field').text().trim(), '*');
});

test('it does not display an asterisks if content.isRequred set to false', function(assert) {
  this.set('content', Ember.Object.create({ ident: 'test' , text: 'Test data-picker', isRequired: false}));
  this.render(template);
  assert.equal(this.$('p span.required-field').text().trim(), '');
});

test('it does not display an asterisks if content.isRequred set to true and the answer.value is set', function(assert) {
  this.set('content', Ember.Object.create({ ident: 'test' , text: 'Test data-picker', isRequired: true}));
  this.set('answer', Ember.Object.create({ wasAnswered: true }));
  this.render(template);
  assert.equal(this.$('p span.required-field').text().trim(), '');
});
