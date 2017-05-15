import {
  moduleForComponent,
  test
} from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('paper-downloads', 'Integration | Component | Paper Downloads', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);

    const docxPaper = make('paper', {
      versionedTexts: [{
        id: 1,
        isDraft: false,
        majorVersion: 1,
        minorVersion: 1,
        fileType: 'docx',
      }]
    });
    this.set('docxPaper', docxPaper);

    const pdfPaper = make('paper', {
      versionedTexts: [{
        id: 2,
        isDraft: false,
        majorVersion: 1,
        minorVersion: 1,
        fileType: 'pdf',
      }]
    });
    this.set('pdfPaper', pdfPaper);

    const pdfAndSourcePaper = make('paper', {
      versionedTexts: [{
        id: 3,
        isDraft: false,
        majorVersion: 1,
        minorVersion: 1,
        fileType: 'pdf',
        sourceType: 'docx'
      }]
    });
    this.set('pdfAndSourcePaper', pdfAndSourcePaper);
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{paper-downloads paper=docxPaper}}
  `);

  assert.equal(this.$('.paper-downloads').length, 1);
});


test('docx versions display download links', function(assert) {
  this.render(hbs`
    {{paper-downloads paper=docxPaper}}
  `);

  assert.equal(this.$('.download-docx').length, 1);
  assert.equal(this.$('.download-pdf').length, 1);
});

test('pdf versions display download links', function(assert) {
  this.render(hbs`
    {{paper-downloads paper=pdfPaper}}
  `);

  assert.equal(this.$('.download-docx').length, 0);
  assert.equal(this.$('.download-pdf').length, 1);
});

test('pdf versions with sources display source and download links', function(assert) {
  this.render(hbs`
    {{paper-downloads paper=pdfAndSourcePaper}}
  `);

  assert.equal(this.$('.download-docx').length, 0);
  assert.equal(this.$('.download-source').length, 1);
  assert.equal(this.$('.download-pdf').length, 1);
});

test('pdf papers with no version fileType', function(assert) {
  const noFileTypeSourcePaperPdf = make('paper', {
    file: {
      file_type: 'pdf',
      pending_url: 'http://pdf-pending-url',
    },
    versionedTexts: [{
      id: 3,
      isDraft: false,
      majorVersion: 1,
      minorVersion: 1,
      fileType: '',
    }]
  });
  this.set('noFileTypeSourcePaperPdf', noFileTypeSourcePaperPdf);
  this.render(hbs`
    {{paper-downloads paper=noFileTypeSourcePaperPdf}}
  `);
  const href = this.$('a.download-pdf');
  assert.equal(href.length, 1, 'download-pdf anchor exists');
  assert.equal(href.attr('href'), 'http://pdf-pending-url');
});

test('docx papers with no version fileType', function(assert) {
  const noFileTypeSourcePaperDoc = make('paper', {
    file: {
      file_type: 'docx',
      pending_url: 'http://doc-pending-url',
    },
    versionedTexts: [{
      id: 4,
      isDraft: false,
      majorVersion: 1,
      minorVersion: 1,
      fileType: '',
    }]
  });
  this.set('noFileTypeSourcePaperDoc', noFileTypeSourcePaperDoc);
  this.render(hbs`
    {{paper-downloads paper=noFileTypeSourcePaperDoc}}
  `);
  const href = this.$('a.download-docx');
  assert.equal(href.length, 1, 'download-docx anchor exists');
  assert.equal(href.attr('href'), 'http://doc-pending-url');
});
