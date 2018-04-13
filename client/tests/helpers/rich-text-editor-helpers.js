/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

export function findEditor(name) {
  let selector = `.rich-text-editor[data-editor='${name}']`;
  let editorId = $(selector).find('iframe').contents().find('body').data('id');
  return window.tinymce.editors[editorId];
}

export function getRichText(name) {
  let editor = findEditor(name);
  return editor.getContent();
}

export function setRichText(name, text) {
  let editor = findEditor(name);
  editor.setContent(text);
  editor.target.triggerSave();
}

export function pasteText(name, text) {
  let editor = findEditor(name);
  let dom = editor.dom;
  let tempBody = dom.add(editor.getBody(), 'div', { }, text);
  editor.fire('PastePostProcess', {node: tempBody, internal: false});
  editor.target.triggerSave();
}

// This isn't strictly needed yet, but there are a number of "paste from Word"
// tickets queued up, and this will make a good helper method. It clones a
// unit test method used in the TinyMCE library itself.
export function setContentFromClipboard(name, content) {
  let editor = findEditor(name);
  editor.setContent('');
  editor.execCommand('mceInsertClipboardContent', false, {content: content});
}

export function editorFireEvent(editorName, eventName) {
  let editor = findEditor(editorName);
  editor.fire(eventName);
}
