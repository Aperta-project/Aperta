import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup } from 'ember-data-factory-guy';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

moduleForComponent('admin-page/email-templates/preview',
  'Integration | Component | Admin Page | Email Templates | Preview', {
    integration: true,
    beforeEach() {
      manualSetup(this.container);
    },
    afterEach() {
      $.mockjax.clear();
    }
  }
);

test('it displays template errors properly', function(assert) {
  this.set('template', Ember.Object.create({id: 1}));
  $.mockjax({
    url: '/api/admin/letter_templates/1/preview',
    status: 422,
    responseText: { errors: [] }
  });
  this.set('dirtyEditorConfig', {model: 'template', properties: ['subject', 'body']});

  // Test display of errors through email-template/edit component
  this.render(hbs`
    {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);

  this.$("[data-test-selector='preview-email']").click();

  return wait().then(() => {
    assert.equal(this.$('.text-danger').text().trim(), 'Please correct errors where indicated.', 'Displays errors if preview template has syntax errors');
  });
});

test('it displays dummy data when clicked on preview button', function(assert) {
  $.mockjax({
    url: '/api/admin/letter_templates/1/preview',
    status: 201,
    responseText: { letter_template: {body: 'dummy data present' } }
  });
  this.set('template', Ember.Object.create({id: 1}));

  this.render(hbs`
    <div id="overlay-drop-zone"></div>
    {{admin-page/email-templates/preview template=template}}
  `);
  this.$("[data-test-selector='preview-email']").click();

  return wait().then(() => {
    assert.textPresent('.overlay-container', 'dummy data present');
  });
});
