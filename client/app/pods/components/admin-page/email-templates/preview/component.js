import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service(),
  classNameBindings: ['preview-email'],
  tagName: 'span',
  visible: false,
  hasErrors: false,
  letterTemplateId: null,
  letterTemplate: null,
  actions: {
    loadPreviewData() {
      this.get('restless')
        .get(`/api/admin/letter_templates/${this.get('letterTemplateId')}/preview`).
        then((data) => {
          this.set('letterTemplate', data.letter_template);
        });
      this.set('visible', true);
    },
    close() {
      this.set('visible', false);
    }
  }
});
