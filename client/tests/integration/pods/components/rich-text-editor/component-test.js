import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import {findEditor, getRichText, setRichText, pasteText, editorFireEvent} from 'tahi/tests/helpers/rich-text-editor-helpers';

moduleForComponent('rich-text-editor', 'Integration | Component | rich text editor', {
  integration: true
});

test('it renders', function(assert) {
  this.set('saveContents', function() {});
  this.render(hbs`{{rich-text-editor ident='foo' onContentsChanged=saveContents}}`);

  let editor = findEditor('foo');
  assert.elementFound(editor);
  assert.equal(getRichText('foo'), '');

  setRichText('foo', 'abc');
  assert.equal(getRichText('foo'), '<p>abc</p>');
});

test('it shows error message', function(assert) {
  let errorMessage = 'Error Message';
  this.set('errorMessages', [errorMessage]);
  this.set('saveContents', function() {});
  this.render(hbs`{{rich-text-editor ident='foo'
                  onContentsChanged=saveContents
                  errorMessages=errorMessages
                  displayText=true}}`);

  assert.elementFound('.error-message', errorMessage);
});

test('it does not wrap content in a <p> tag when editorStyle is inline', function(assert) {
  this.set('saveContents', function() {});
  this.render(hbs`{{rich-text-editor editorStyle='inline' ident='foo' onContentsChanged=saveContents}}`);

  let editor = findEditor('foo');
  assert.elementFound(editor);
  assert.equal(getRichText('foo'), '');

  setRichText('foo', 'abc');
  assert.equal(getRichText('foo'), 'abc');
});

test('it strips <p> and <br> tags when editorStyle is inline', function(assert) {
  this.set('saveContents', function() {});
  this.render(hbs`{{rich-text-editor editorStyle='inline' ident='foo' onContentsChanged=saveContents}}`);

  let editor = findEditor('foo');
  assert.elementFound(editor);
  assert.equal(getRichText('foo'), '');

  setRichText('foo', '<p>a<br>b<br />c</p>');
  assert.equal(getRichText('foo'), 'abc');
});

test('it strips empty <p></p> tags from a pasted word text', function(assert) {
  this.set('saveContents', function() {});
  this.render(hbs`{{rich-text-editor editorStyle='inline' ident='bar' onContentsChanged=saveContents}}`);

  let editor = findEditor('bar');
  assert.elementFound(editor);
  assert.equal(getRichText('bar'), '');
  Ember.run(function() {
    pasteText('bar', '<p>foo</p><p>&nbsp;</p><p>bar</p>');
    // after striping off empty paragraphs, TinymCE returns a div class with
    // the rest of the text(the text sits in between this div) , this occur
    // when we use the {format: raw} which we can get rid off for this test
    assert.ok(findEditor('bar').getContent({format: 'raw'}).indexOf('<p>foo</p><p>bar</p>') !== -1);
  });
});

test(`it sends 'onContentsChanged' after keyed input`, function(assert) {
  assert.expect(1);
  this.set('value', '<p>Old</p>');
  this.set('changeStub', function(newVal) {
    assert.equal(newVal, '<p>New</p>', 'it calls the action with the new value');
  });
  this.render(hbs`{{rich-text-editor
                  value=value
                  onContentsChanged=(action changeStub)}}`);
  let editor = window.tinymce.activeEditor;
  editor.setContent('New');
  editor.target.triggerSave();
});


test('checking the focusOut action triggers after editor is disabled', function(assert) {
  var focusOutCount = 0;
  this.set('focusOutStub', function() {
    focusOutCount = focusOutCount + 1;
  });
  this.set('saveContents', function() {});

  this.set('disabled', false);
  let template = hbs`{{rich-text-editor
                  value=value
                  ident='test-editor'
                  disabled=disabled
                  onContentsChanged=saveContents
                  focusOut=(action focusOutStub)}}`;
  this.render(template);

  // When 'disabled' is toggled to true, the tinymce component is swapped out for a plain
  // text field. The focusOut action has to be reattached when 'disabled' is toggled back to false
  editorFireEvent('test-editor', 'blur');
  assert.equal(focusOutCount, 1, 'focusOut was called when the editor was initialized in an enabled state');

  this.set('disabled', true);
  this.set('disabled', false);
  // The focusOut passed in handler function is now attached to the rich text editor blur event.
  editorFireEvent('test-editor', 'blur');

  assert.equal(focusOutCount, 2, 'focusOut was called again after reenabling the editor');
});

test('contents do not update from upstream changes when editor is active', function(assert) {
  const initialValue = '<p>pickachu</p>';
  this.set('value', initialValue);
  this.set('saveContents', function() {});
  const template = hbs`{{rich-text-editor
                      value=value
                      ident='test-editor'
                      onContentsChanged=saveContents}}`;
  this.render(template);
  const editor = findEditor('test-editor');
  editorFireEvent('test-editor', 'focus'); // get focus
  assert.equal(editor.getContent(), initialValue, 'initial value should be set');
  this.set('value', '<p>bulbasaur</p>');
  assert.equal(editor.getContent(), initialValue, 'the contents should not change when the editor has focus');
  editorFireEvent('test-editor', 'blur'); // lose focus
  const upstreamValue = '<p>charmander</p>';
  this.set('value', upstreamValue);
  assert.equal(editor.getContent(), upstreamValue, 'the contents should change if the editor does not have focus');
});

test('it has no toolbar buttons when editorStyle is plain', function(assert) {
  this.set('saveContents', function() {});
  this.render(hbs`{{rich-text-editor editorStyle='plain' ident='foo' onContentsChanged=saveContents}}`);

  let editor = findEditor('foo');
  assert.elementFound(editor);
  assert.elementNotFound('.mce-widget button');
});

test('it has toolbar buttons when editorStyle is not plain', function(assert) {
  this.set('saveContents', function() {});
  this.render(hbs`{{rich-text-editor ident='foo' onContentsChanged=saveContents}}`);

  let editor = findEditor('foo');
  assert.elementFound(editor);
  assert.elementFound('.mce-widget button .mce-i-bold');
});
