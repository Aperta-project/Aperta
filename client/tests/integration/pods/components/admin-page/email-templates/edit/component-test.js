/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup, mockUpdate } from 'ember-data-factory-guy';
import sinon from 'sinon';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

moduleForComponent('admin-page/email-templates/edit',
  'Integration | Component | Admin Page | Email Templates | Edit', {
    integration: true,
    beforeEach() {
      manualSetup(this.container);
      this.registry.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
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
  // Saving letter templates now triggers a reload, so we need to noop that for tests
  template.reload = function() {};

  let saveStub = sinon.stub(template, 'save');
  saveStub.returns(Ember.RSVP.Promise.resolve());
  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);

  // This is necessary because the save button doesn't enable until there is a keypress event on any of the fields
  generateKeyEvent.call(this, 20);
  this.$('.button-primary').click();

  return wait().then(() => {
    assert.elementFound('.button-primary[disabled]');
    assert.equal(this.$('span.text-success').text(), 'Your changes have been saved.');
  });
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
  let template = FactoryGuy.make('letter-template', {subject: 'foo', body: 'bar'});
  // see https://github.com/danielspaniel/ember-data-factory-guy#using-fails-method
  mockUpdate(template).fails({status: 422, response: {errors: {subject: 'Syntax Error'}}});

  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);

  generateKeyEvent.call(this, 32);
  this.$('.template-subject').val('{{ name }').blur();
  this.$('.button-primary').click();

  return wait().then(() => {
    assert.equal(this.$('.error>ul>li').text().trim(), 'Syntax Error', 'has the right text');
  });
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
