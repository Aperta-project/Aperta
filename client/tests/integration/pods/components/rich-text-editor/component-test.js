import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import {findEditor, getRichText, setRichText} from 'tahi/tests/helpers/rich-text-editor-helpers';

moduleForComponent('rich-text-editor', 'Integration | Component | rich text editor', {
  integration: true
});

test('it renders', function(assert) {
  let saveContents = function() {};
  this.set('saveContents', saveContents);

  this.render(hbs`{{rich-text-editor ident='foo' onContentsChanged=saveContents}}`);

  let editor = findEditor('foo');
  assert.elementFound(editor);
  assert.equal(getRichText('foo'), '');

  setRichText('foo', 'abc');
  assert.equal(getRichText('foo'), '<p>abc</p>');
});

test('it shows error message', function(assert) {
  let saveContents = function() {};
  let errorMessage = 'Error Message';
  this.set('saveContents', saveContents);
  this.set('errorMessages', [errorMessage]);

  this.render(hbs`{{rich-text-editor ident='foo'
                  onContentsChanged=saveContents
                  errorMessages=errorMessages
                  displayText=true}}`);

  assert.elementFound('.error-message', errorMessage);
});
