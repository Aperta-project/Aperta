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
