import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('related-article',
                   'Integration | Component | related article',
                   {integration: true});

var relatedArticle = {
  id: 3,
  linkedDOI: 'journal.pcbi.1004816',
  linkedTitle: 'The best linked article in texas',
  additionalInfo: 'This information is additional',
  sendManuscriptsTogether: true,
  sendLinkToApex: true
};

var template = hbs`{{related-article
                       relatedArticle=relatedArticle
                       editState=editable}}`;

function setup(context, editable) {
  context.set('relatedArticle', relatedArticle);
  context.set('editable', editable);
  context.render(template);
}


// When not editable:

test('Shows all data when not editable', function(assert){
  setup(this);

  assert.textPresent(
    '.related-article-doi',
    relatedArticle.linkedDOI,
    'doi is present');

  assert.textPresent(
    '.related-article-title',
    relatedArticle.linkedTitle,
    'title is present');

  assert.textPresent(
    '.related-article-additional-info',
    relatedArticle.additionalInfo,
    'additional info is present');
});

test('Hides send together text if attribute is false', function(assert){
  relatedArticle.sendManuscriptsTogether = false;
  setup(this);

  assert.elementNotFound(
    '.related-article-publish-together',
    'publish together bullet is not present');
});

test('Shows send together text when attribute is true', function(assert){
  relatedArticle.sendManuscriptsTogether = true;
  setup(this);

  assert.elementFound(
    '.related-article-publish-together',
    'publish together bullet is present');
});

test('Hides send to apex text if attribute is false', function(assert){
  relatedArticle.sendLinkToApex = false;
  setup(this);

  assert.elementNotFound(
    '.related-article-send-to-apex',
    'send to apex bullet is not present');
});

test('Shows send to apex text if attribute is false', function(assert){
  relatedArticle.sendLinkToApex = true;
  setup(this);

  assert.elementFound(
    '.related-article-send-to-apex',
    'publish together bullet is present');
});

test('Hides all inputs when not editing', function(assert) {
  setup(this);
  assert.elementNotFound('input', 'no inputs are present');
});

test('Can be edited', function(assert) {
  setup(this);

  this.$('.related-article').hover();

  assert.elementFound(
    '.related-article-send-to-apex',
    'publish together bullet is present');

  Ember.run(function() {
    this.$('.related-article-edit').click();

    assert.elementFound(
      '.related-article-title-input',
      'Enters the editing state');
  });
});

test('Can be deleted', function(assert) {
  assert.expect(2);
  relatedArticle.destroyRecord = function() {
    assert.ok(true, 'Calls destroy');
  };
  setup(this);

  this.$('.related-article').hover();

  assert.elementFound(
    '.related-article-delete',
      'Trashcan is visible on hover');

  this.$('.related-article-delete').click();
});

// When editable:

test('Shows inputs, filled in, when editing', function(assert){
  setup(this, true);

  assert.inputPresent(
    '.related-article-title-input',
    relatedArticle.linkedTitle,
    'title input is present'
  );

  assert.inputPresent(
    '.related-article-doi-input',
    relatedArticle.linkedDOI,
    'DOI input is present'
  );

  assert.inputPresent(
    '.related-article-additional-info-input',
    relatedArticle.additionalInfo,
    'additional info input is present'
  );

  assert.checkboxPresent(
    '.related-article-send-to-apex-input input',
    relatedArticle.sendLinkToApex,
    'send link input is present'
  );
});

test('Save saves new values', function(assert){
  assert.expect(2);
  relatedArticle.save = function() {
    assert.ok(true, 'Calls save');
  };

  setup(this, true);
  assert.elementFound('.related-article-save', 'save button is present');
  this.$('.related-article-save').click();
});

test('Cancel resets all values', function(assert){
  assert.expect(2);
  relatedArticle.rollback = function() {
    assert.ok(true, 'Calls rollback');
  };

  setup(this, true);
  assert.elementFound('.related-article-cancel', 'cancel button is present');
  this.$('.related-article-cancel').click();
});
