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

test('it disables preview button if template has errors', function(assert) {
  this.set('hasErrors', true);
  this.set('template', Ember.Object.create({id: 1}));
  this.render(hbs`
    {{admin-page/email-templates/preview letterTemplateId=template.id hasErrors=hasErrors}}
  `);
  assert.elementFound("[data-test-selector='preview-email'][disabled]");
});

test('it displays dummy data when clicked on preview button', function(assert) {
  $.mockjax({
    url: '/api/admin/letter_templates/1/preview',
    status: 200,
    responseText: { letter_template: {body: 'dummy data present' } }
  });
  this.set('template', Ember.Object.create({id: 1}));

  this.render(hbs`
    <div id="overlay-drop-zone"></div>
    {{admin-page/email-templates/preview letterTemplateId=template.id hasErrors=hasErrors}}
  `);
  this.$("[data-test-selector='preview-email']").click();

  return wait().then(() => {
    assert.textPresent('.overlay-container', 'dummy data present');
  });
});
