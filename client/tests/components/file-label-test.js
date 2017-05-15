import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('file-label', 'Integration | Component | file label', {
  integration: true,

  beforeEach() {
    this.set('docxFileName', 'test.docx');
    this.set('docFileName', 'test.doc');
    this.set('pdfFileName', 'test.pdf');
    this.set('zipFileName', 'test.zip');
    this.set('texFileName', 'test.tex');
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{file-label fileName=docxFileName}}
  `);

  assert.equal(this.$('.file-label').length, 1);
});

test('it shows PDF correctly', function(assert) {
  this.render(hbs`
    {{file-label fileName=pdfFileName}}
  `);

  assert.textPresent('.file-label', 'PDF');
  assert.elementFound('.fa-file-pdf-o', 'The pdf icon appears');
});

test('it shows DOC correctly', function(assert) {
  this.render(hbs`
    {{file-label fileName=docFileName}}
  `);

  assert.textPresent('.file-label', 'Word');
  assert.elementFound('.fa-file-word-o', 'The word doc icon appears');
});

test('it shows DOCX correctly', function(assert) {
  this.render(hbs`
    {{file-label fileName=docxFileName}}
  `);

  assert.textPresent('.file-label', 'Word');
  assert.elementFound('.fa-file-word-o', 'The word doc icon appears');
});

test('it shows ZIP correctly', function(assert) {
  this.render(hbs`
    {{file-label fileName=zipFileName}}
  `);

  assert.textPresent('.file-label', 'Zip');
  assert.elementFound('.fa-file-archive-o', 'The archive icon appears');
});

test('it shows LaTeX correctly', function(assert) {
  this.render(hbs`
    {{file-label fileName=texFileName}}
  `);

  assert.textPresent('.file-label', 'LaTeX');
  assert.elementFound('.fa-file-text-o', 'The text icon appears');
});
