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
  assert.equal(this.$('#subject').val(), template.get('subject'));
  assert.equal(this.$('#body').val(), template.get('body'));
});

test('it prevents the model from saving if a field is blank and displays validation errors', function(assert){
  assert.expect(2);
  
  let template = FactoryGuy.make('letter-template', {subject: '', body: 'bar'});
  sinon.spy(template, 'save');
  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template}}
  `);

  Ember.run(() => {
    this.$('#subject').blur();
    this.$('.edit-email-button').click();
  });
  
  assert.elementFound('.error');
  assert.equal(template.save.called, false);
});

test('it displays a success message if save succeeds and disables save button', function(assert) {
  assert.expect(2);

  let template = FactoryGuy.make('letter-template', {subject: 'foo', body: 'bar'});
  this.set('saved', true);
  this.set('message', 'Your changes have been saved.');
  this.set('messageType', 'success');

  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template saved=saved message=message messageType=messageType}}
  `);

  assert.elementFound('.button-primary[disabled]');
  assert.equal(this.$('span.text-success').text(), 'Your changes have been saved.');
});

test('it displays an error message if save fails', function(assert) {
  assert.expect(2);

  let template = FactoryGuy.make('letter-template', { subject: 'foo', body: 'bar'});
  this.set('saved', false);
  this.set('message', 'Please correct errors where indicated.');
  this.set('messageType', 'danger');

  this.set('templalte', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template saved=saved message=message messageType=messageType}}
  `);

  assert.elementNotFound('.button-primary[disabled]');
  assert.equal(this.$('span.text-danger').text(), 'Please correct errors where indicated.');
});


test('it warns user if input field has invalid content', function(assert) {
  assert.expect(2);

  let template = FactoryGuy.make('letter-template', {subject: 'foo', body: 'bar'});
  this.set('template', template);

  this.render(hbs`
    {{admin-page/email-templates/edit template=template}}
  `);
  
  Ember.run(() => {
    this.$('#subject').val('').blur();
  });

  assert.elementFound('.error');

  Ember.run(() => {
    this.$('#subject').val('foo').blur();
    this.$('#body').val('').blur();
  });

  assert.elementFound('.error');
});
