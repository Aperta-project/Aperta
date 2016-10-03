import PageObject, {
  clickable,
  fillable,
  text,
  collection,
  isVisible
} from 'ember-cli-page-object';

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
      setLabel(text) {
        return $(this.scope + ' label.editable').html(text).keyup();
      },
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
      setText(text) {
        return $(this.scope + ' div.editable').html(text).keyup();
      },
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
      setText(text){
        return $(this.scope + ' div.editable').html(text).keyup();
      },
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
      setBody(text){
        return $(this.scope + ' div.editable').html(text).keyup();
      },
      setSubject: fillable('input', {scope: '.editing'}),
      subject: text('.item-subject'),
      body: text('.item-text'),
      save: clickable('.edit-actions .button-secondary'),
      send: clickable('.email-send-participants'),
      sendConfirm: clickable('.send-email-action')
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
