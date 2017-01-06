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
      labelText: contentEditable('label.editable'),
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
