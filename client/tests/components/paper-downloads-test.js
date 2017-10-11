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
        updatedAt: '2017-01-30T22:51:16.000Z',
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
        updatedAt: '2017-01-30T22:51:16.000Z',
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
        updatedAt: '2017-01-30T22:51:16.000Z',
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

test('it displays version number and date completed', function(assert) {
  this.render(hbs`
    {{paper-downloads paper=docxPaper}}
  `);

  assert.ok(this.$('td.paper-downloads-version').text(), 'v1.1 - Jan 30, 2017');
});

