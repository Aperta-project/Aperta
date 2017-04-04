import { moduleForComponent, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import customAssertions from '../../helpers/custom-assertions';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';


moduleForComponent(
  'supporting-information-file',
  'Integration | Component | supporting information file',
  {
    integration: true,
    beforeEach() {
      initTruthHelpers();
      customAssertions();
      manualSetup(this.container);
    }
  });


test('user can edit an existing file and then cancel', function(assert) {

  this.set('fileProxy', Ember.Object.create({
    object: make('supporting-information-file', {titleHtml: 'Old Title', category: 'Figure', status: 'done'})
  }));

  const template = hbs`{{supporting-information-file isEditable=true model=fileProxy}}`;

  this.render(template);

  this.$('.si-file-edit-icon').click();
  this.$('.si-file-title-input [contenteditable]').html('New Title').keyup();
  this.$('.si-file-cancel-edit-button').click();

  assert.textPresent('.si-file-title', 'Old Title', 'title gets reverted on cancel');

});

test('validates attributes and updates the file on save', function(assert) {
  assert.expect(2);
  this.set('fileProxy', Ember.Object.create({
    object: make('supporting-information-file', {titleHtml: 'Old Title', category: 'Figure', status: 'done'}),
    validateAll() {
      assert.ok(true, 'validateAll is called');
    },
    validationErrorsPresent() {
      return false;
    }
  }));

  this.set('updateStub', function() { assert.ok(true, 'update action is called'); });

  const template = hbs`{{supporting-information-file
                       isEditable=true
                       model=fileProxy
                       updateFile=(action updateStub)}}`;

  this.render(template);

  this.$('.si-file-edit-icon').click();
  this.$('.si-file-save-edit-button').click();

});

test('does not validate original attributes on cancel', function(assert) {

  this.set('fileProxy', Ember.Object.create({
    object: make('supporting-information-file', {titleHtml: 'Old Title', category: 'Figure', status: 'done'}),
    validateAll() {
      assert.ok(false, 'validateAll should not be called');
    },
    validationErrorsPresent() {
      return false;
    }
  }));

  let template = hbs`{{supporting-information-file isEditable=true model=fileProxy}}`;

  this.render(template);

  this.$('.si-file-edit-icon').click();
  this.$('.si-file-title-input [contenteditable]').html('New Title').keyup();
  this.$('.si-file-cancel-edit-button').click();
  assert.textPresent('.si-file-title', 'Old Title', 'title gets reverted on cancel');

});
