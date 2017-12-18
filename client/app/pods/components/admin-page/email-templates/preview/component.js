import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service(),
  store: Ember.inject.service(),
  classNameBindings: ['preview-email'],
  tagName: 'span',
  visible: false,
  template: null,
  previewTemplate: null,
  actions: {
    loadPreviewData() {
      let data = {
        letter_template:
        { body: this.get('template.body'),
          subject: this.get('template.subject'),
          cc: this.get('template.cc'),
          bcc: this.get('template.bcc')
        }
      };
      let adapter = this.get('store').adapterFor('application');
      adapter.ajax(`/api/admin/letter_templates/${this.get('template.id')}/preview`, 'POST', {data}).
        then((data) => {
          this.set('previewTemplate', data.letter_template);
          this.set('visible', true);
          this.sendAction('clearErrors');
        }).catch((error) => {
          this.set('visible', false);
          this.sendAction('parseErrors', error);
        });
    },
    close() {
      this.set('visible', false);
    }
  }
});
