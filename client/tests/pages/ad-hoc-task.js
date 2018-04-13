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

import PageObject, {
  clickable,
  fillable,
  text,
  collection,
  isVisible
} from 'ember-cli-page-object';

import Ember from 'ember';

import { findElementWithAssert } from 'ember-cli-page-object/extend';

let contentEditable = function(selector, options = {}) {
  return {
    isDescriptor: true,
    value(text) {
      let setText = () => {
        findElementWithAssert(this, selector, options).html(text).keyup();
      };

      // If andThen exists, we're in the acceptance test context.
      if (typeof andThen === 'function') {
        wait().then(setText);
      } else {
        Ember.run(null, setText);
      }

      return this;
    }
  };
};

export default PageObject.create({
  titlePencil: clickable('h1.inline-edit .fa-pencil'),
  titleInput: fillable('.large-edit input[name=title]'),
  titleSave: clickable('.large-edit .button--green:contains("Save")'),
  title: text('h1.inline-edit'),

  setTitle(text) {
    this.titlePencil()
        .titleInput(text)
        .titleSave();
  },

  toolbarVisible: isVisible('.adhoc-content-toolbar'),
  toolbar: {
    scope: '.adhoc-content-toolbar',
    open: clickable('.button-primary'),
    addAttachment: clickable('.adhoc-toolbar-item--image'),
    addCheckbox: clickable('.adhoc-toolbar-item--list'),
    addEmail: clickable('.adhoc-toolbar-item--email'),
    addLabel: clickable('.adhoc-toolbar-item--label'),
    addText: clickable('.adhoc-toolbar-item--text')
  },

  checkboxes: collection({
    itemScope: '.task-body .inline-edit-body-part.checkbox',
    item: {
      edit: clickable('.fa-pencil'),
      trash: clickable('.fa-trash'),
      confirmTrash: clickable('.delete-button'),
      editVisible: isVisible('.fa-pencil'),
      deleteVisible: isVisible('.fa-trash'),
      labelText: contentEditable('.editable.inline-edit-display'),
      label: text('label:nth(0)'),
      save: clickable('.edit-actions .button-secondary'),
    }
  }),

  textboxes: collection({
    itemScope: '.task-body .inline-edit-body-part.text',
    item: {
      edit: clickable('.fa-pencil'),
      trash: clickable('.fa-trash'),
      confirmTrash: clickable('.delete-button'),
      editVisible: isVisible('.fa-pencil'),
      setText: contentEditable('div.editable'),
      deleteVisible: isVisible('.fa-trash'),
    }
  }),

  labels: collection({
    itemScope: '.task-body .inline-edit-body-part.adhoc-label',
    item: {
      edit: clickable('.fa-pencil'),
      trash: clickable('.fa-trash'),
      confirmTrash: clickable('.delete-button'),
      editVisible: isVisible('.fa-pencil'),
      deleteVisible: isVisible('.fa-trash'),
      labelText: contentEditable('div.editable'),
      text: text('.item-text'),
      save: clickable('.edit-actions .button-secondary')
    }
  }),

  emails: collection({
    itemScope: '.task-body .inline-edit-body-part.email',
    item: {
      edit: clickable('.fa-pencil'),
      trash: clickable('.fa-pencil'),
      confirmTrash: clickable('.delete-button'),
      editVisible: isVisible('.fa-pencil'),
      deleteVisible: isVisible('.fa-trash'),
      setBody: contentEditable('div.editable'),
      setSubject: fillable('input', {scope: '.editing'}),
      subject: text('.item-subject'),
      body: text('.item-text'),
      save: clickable('.edit-actions .button-secondary'),
      send: clickable('.email-send-participants'),
      cancel: clickable('.bodypart-overlay .button-link'),
      sendConfirm: clickable('.send-email-action'),
      sendConfirmVisible: isVisible('.send-email-action'),
      sendConfirmDisabled: isVisible('.send-email-action.button--disabled'),
      recipients: collection({
        itemScope: '.participant-selector-user',
        item: {
          remove: clickable('.participant-selector-user-remove')
        }
      })
    }
  }),

  attachments: collection({
    itemScope: '.task-body .inline-edit-body-part.attachments',
    item: {
      edit: clickable('.fa-pencil'),
      trash: clickable('.fa-pencil'),
      confirmTrash: clickable('.delete-button'),
      editVisible: isVisible('.fa-pencil'),
      deleteVisible: isVisible('.fa-trash'),
    }
  })
});
