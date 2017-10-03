import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import sinon from 'sinon';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

moduleForComponent('admin-page/email-templates/edit',
  'Integration | Component | Admin Page | Email Templates | Edit', {
    integration: true,
    beforeEach() {
      manualSetup(this.container);
      this.set('dirtyEditorConfig', {model: 'template', properties: ['subject', 'body']});
    }
  }
);

test('it populates input fields with model data', function(assert) {
  assert.expect(2);

  let template = FactoryGuy.make('letter-template', {subject: 'foo', body: 'bar'});

  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);
  assert.equal(this.$('.template-subject').val(), template.get('subject'));
  assert.equal(this.$('.template-body').val(), template.get('body'));
});

test('it displays validation errors if a field is empty', function(assert){
  assert.expect(1);

  let template = FactoryGuy.make('letter-template', {subject: '', body: 'bar'});
  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);

  this.$('.template-subject').blur();

  assert.ok(this.$('span').text().trim(), 'This field is required.');
});

test('it displays a success message if save succeeds and disables save button', function(assert) {
  assert.expect(2);

  let template = FactoryGuy.make('letter-template', { subject: 'foo', body: 'bar'});

  let saveStub = sinon.stub(template, 'save');
  saveStub.returns(Ember.RSVP.Promise.resolve());
  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);

  // This is necessary because the save button doesn't enable until there is a keypress event on any of the fields
  generateKeyEvent.call(this, 20);
  this.$('.button-primary').click();

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
    {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);

  generateKeyEvent.call(this, 32);
  this.$('.button-primary').click();

  return wait().then(() => {
    assert.elementNotFound('.button-primary[disabled]');
    assert.equal(this.$('span.text-danger').text(), 'Please correct errors where indicated.');
  });
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
    {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);

  generateKeyEvent.call(this, 32);
  this.$('.template-subject').val('{{ name }').blur();
  this.$('.button-primary').click();

  return wait().then(() => assert.equal(this.$('.error>ul>li').text().trim(), 'Syntax Error'));
});

test('clicking the edit icon allows a user to edit the template name', function(assert) {
  const template = FactoryGuy.make('letter-template', { name: 'Rescind Email', subject: 'Rescinding a Review Task', body: 'foobar' });

  this.set('template', template);

  this.render(hbs`
  {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);

  assert.ok(this.$('h2').text().trim(), template.get('name'));
  assert.elementFound('.fa.fa-pencil');
  this.$('.fa.fa-pencil').click();
  assert.elementFound('input.template-name');
});

test('it displays errors if you try to submit without a template name', function(assert) {
  const template = FactoryGuy.make('letter-template', { name: 'Rescind Email', subject: 'Rescinding a Review Task', body: 'foobar' });
  
  this.set('template', template);
  
  this.render(hbs`
    {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);

  this.$('.fa.fa-pencil').click();
  assert.elementFound('input.template-name');

  generateKeyEvent.call(this, 32);
  this.$('input.template-name').val('').blur();

  const expectedText = `The email template name of "${this.get('template.name')}" is already taken for this journal. Please give your template a new name.`;
  assert.ok(this.$('span.error').text().trim(), 'This field is required.');
  assert.ok(this.$('span.error').text().trim(), expectedText);
  assert.elementNotFound('.edit-email-button[disabled]');
});

let generateKeyEvent = function(keyCode) {
  const e = Ember.$.Event('keydown');
  e.which = keyCode;
  e.keyCode = keyCode;
  Ember.run(() => this.$('.template-subject').trigger(e));
};
