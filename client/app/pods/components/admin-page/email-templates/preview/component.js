import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service(),
  classNameBindings: ['preview-email'],
  tagName: 'span',
  visible: false,
  hasErrors: false,
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
      this.get('restless')
        .post(`/api/admin/letter_templates/${this.get('template.id')}/preview`, data).
        then((data) => {
          this.set('previewTemplate', data.letter_template);
        });
      this.set('visible', true);
    },
    close() {
      this.set('visible', false);
    }
  }
});
