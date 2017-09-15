import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import sinon from 'sinon';
import Ember from 'ember';

moduleForComponent('admin-page/email-templates/edit',
  'Integration | Component | Admin Page | Email Templates | Edit', {
    integration: true,
    beforeEach() {
      manualSetup(this.container);
    }
  }
);

test('it populates input fields with model data', function(assert) {
  assert.expect(2);

  let template = FactoryGuy.make('letter-template', {subject: 'foo', body: 'bar'});

  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template}}
  `);
  assert.equal(this.$('.template-subject').val(), template.get('subject'));
  assert.equal(this.$('.template-body').val(), template.get('body'));
});

test('it displays validation errors if a field is empty', function(assert){
  assert.expect(1);
  
  let template = FactoryGuy.make('letter-template', {subject: '', body: 'bar'});
  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template}}
  `);

  Ember.run(() => {
    this.$('.template-subject').blur();
  });
  
  assert.ok(this.$('span').text().trim(), 'This field is required.');
});

test('it displays a success message if save succeeds and disables save button', function(assert) {
  assert.expect(2);

  let template = FactoryGuy.make('letter-template', { subject: 'foo', body: 'bar'});

  let saveStub = sinon.stub(template, 'save');
  saveStub.returns(Ember.RSVP.Promise.resolve());
  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template}}
  `);

  // This is necessary because the save button doesn't enable until there is a keypress event on any of the fields
  Ember.run(() => generateKeyEvent.call(this, 20));
  Ember.run(() => this.$('.button-primary').click());

  assert.elementFound('.button-primary[disabled]');
  assert.equal(this.$('span.text-success').text(), 'Your changes have been saved.');
});

test('it displays an error message if save fails', function(assert) {
  assert.expect(2);

  let template = FactoryGuy.make('letter-template', { subject: '', body: 'bar'});

  let saveStub = sinon.stub(template, 'save');
  saveStub.returns(Ember.RSVP.Promise.reject());

  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template}}
  `);

  Ember.run(() => generateKeyEvent.call(this, 32));
  Ember.run(() => this.$('.button-primary').click());

  assert.elementNotFound('.button-primary[disabled]');
  assert.equal(this.$('span.text-danger').text(), 'Please correct errors where indicated.');
});


test('it warns user if input field has invalid content', function(assert) {
  assert.expect(1);

  let template = FactoryGuy.make('letter-template', {subject: 'foo', body: 'bar'});

  let saveStub = sinon.stub(template, 'save');
  saveStub.returns(Ember.RSVP.Promise.reject(
    { errors: [ { source: { pointer: '/subject'}, detail: 'Syntax Error'}]})
  );
  
  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template}}
  `);
  
  Ember.run(() => generateKeyEvent.call(this, 32));
  Ember.run(() => this.$('.template-subject').val('{{ name }').blur());
  Ember.run(() => this.$('.button-primary').click());

  assert.equal(this.$('.error>ul>li').text().trim(), 'Syntax Error');
});

let generateKeyEvent = function(keyCode) {
  const e = Ember.$.Event('keydown');
  e.which = keyCode;
  e.keyCode = keyCode;
  this.$('.template-subject').trigger(e);
};