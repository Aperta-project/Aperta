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
  assert.textPresent('p', `This may be due to images, audio, video, or other
    objects embedded in the original manuscript file.
    You can download the manuscript to
    your computer to view it.
    If you would like to contact us, you can reach us via our
    Feedback form.`, 'paper is submitted but cannot be rendered');
});

test('paper is not submitted and preview fails', function(assert) {
  this.set('paper', {
    'isSubmitted': false,
    'previewFail': true
  });
  this.render(template);
  assert.textPresent('p', `If you are using an unsupported browser, please try a different web browser, or you can download the manuscript to your computer to view it.`, 'paper is not submitted and preview fails (unsupported browser)');
});

test('paper is not submitted, preview did not fail but paper could not be rendered', function(assert) {
  this.set('paper', {
    'isSubmitted': false,
    'previewFail': false
  });
  this.render(template);
  assert.textPresent('h3', 'Your file was uploaded successfully, but we were unable to render a preview at this time.', 'paper is not submitted, preview did not fail but rendered failed (description)');
});
