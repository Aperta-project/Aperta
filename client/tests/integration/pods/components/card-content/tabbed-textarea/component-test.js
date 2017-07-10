import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';

moduleForComponent(
  'card-content/tabbed-textarea',
  'Integration | Component | card content | tabbed textarea',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.set('actionStub', function() {});
    }
  }
);

let annotationTemplate = hbs`{{card-content/tabbed-textarea
          annotationChanged=(action actionStub)
          showAnnotation=true
          annotation='annotation test'}}`;

test(`it can render annotation text alone`, function(assert) {
  this.render(annotationTemplate);
  assert.elementFound('.annotation-text');
  assert.elementNotFound('.instruction-text');
});

let instructionTemplate = hbs`{{card-content/tabbed-textarea
          annotationChanged=(action actionStub)
          showAnnotation=false
          instructionText='instruction test'}}`;

test(`it can render instruction text alone`, function(assert) {
  this.render(instructionTemplate);
  assert.textPresent('.instruction-text', 'instruction test');
  assert.elementNotFound('.annotation-text');
});

let combinedTemplate = hbs`{{card-content/tabbed-textarea
          annotationChanged=(action actionStub)
          showAnnotation=true
          annotation='annotation test'
          instructionText='instruction test'}}`;

test(`it can render cobined text together`, function(assert) {
  this.render(combinedTemplate);
  assert.elementFound('.annotation-text');
  assert.textPresent('.instruction-text', 'instruction test');
});

test(`it sends 'annotationChanged' on change`, function(assert) {
  assert.expect(1);
  this.set('actionStub', function(e) {
    assert.equal(e.target.value, 'changed value');
  });
  this.render(annotationTemplate);
  this.$('textarea.tabbed-textarea').val('changed value').trigger('change');
});
