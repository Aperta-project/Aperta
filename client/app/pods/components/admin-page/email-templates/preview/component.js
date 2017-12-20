import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  classNameBindings: ['preview-email'],
  tagName: 'span',
  visible: false,
  template: null,
  previewTemplate: null,

  actions: {
    loadPreviewData() {
      this.get('template').preview().then((data) => {
          this.get('template').clearErrors();
          this.set('previewTemplate', data.letter_template);
          this.set('visible', true);
        }).catch((error) => {
          this.sendAction('parseErrors', error);
        });
    },
    close() {
      this.set('visible', false);
    }
  }
});
