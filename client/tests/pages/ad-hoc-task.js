import PageObject, {
  clickable,
  fillable,
  text,
  collection,
  isVisible
} from 'ember-cli-page-object';

export default PageObject.create({
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
      delete: clickable('.fa-trash'),
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
      delete: clickable('.fa-trash'),
      editVisible: isVisible('.fa-pencil'),
      deleteVisible: isVisible('.fa-trash'),
    }
  }),

  labels: collection({
    itemScope: '.task-body .inline-edit-body-part.adhoc-label',
    item: {
      edit: clickable('.fa-pencil'),
      delete: clickable('.fa-trash'),
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
      delete: clickable('.fa-pencil'),
      editVisible: isVisible('.fa-pencil'),
      deleteVisible: isVisible('.fa-trash'),
      setBody(text){
        return $(this.scope + ' div.editable').html(text).keyup();
      },
      setSubject: fillable('input', {scope: '.editing'}),
      subject: text('.item-subject'),
      body: text('.item-text'),
      save: clickable('.edit-actions .button-secondary')
    }
  }),

  attachments: collection({
    itemScope: '.task-body .inline-edit-body-part.attachments',
    item: {
      edit: clickable('.fa-pencil'),
      delete: clickable('.fa-pencil'),
      editVisible: isVisible('.fa-pencil'),
      deleteVisible: isVisible('.fa-trash'),
    }
  })
});
