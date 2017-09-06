import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import {findEditor, getRichText, setRichText, pasteText} from 'tahi/tests/helpers/rich-text-editor-helpers';

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

  pasteText('bar', '<p></p>this is <p></p>a pasted text<p></p>');
  assert.equal(getRichText('bar'), 'this is a pasted text');
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
