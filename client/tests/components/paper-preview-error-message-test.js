import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';


moduleForComponent('paper-preview-error-message', 'Integration | Component | paper-preview-error-message', {
  integration: true,
});

let template = hbs`{{paper-preview-error-message paper=paper}}`;

test('paper is submitted without errors but cannot be rendered', function(assert) {
  this.set('paper', {
    'isSubmitted': true,
  });
  this.render(template);
  assert.elementFound('h3.error-submitted');
});

test('paper is not submitted and preview fails', function(assert) {
  this.set('paper', {
    'isSubmitted': false,
    'previewFail': true
  });
  this.render(template);
  assert.elementFound('h3.error-preview-fail');
});

test('paper is not submitted, preview did not fail but paper could not be rendered', function(assert) {
  this.set('paper', {
    'isSubmitted': false,
    'previewFail': false
  });
  this.render(template);
  assert.elementFound('h3.error-preview-not-fail');
});
