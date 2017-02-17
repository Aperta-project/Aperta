import Ember from 'ember';

export default Ember.Component.extend({
  journal: null,
  classNames: ['admin-journal-settings'],
  settings: [],
  pdfCssSaveStatus: '',
  manuscriptCssSaveStatus: '',
  showEditCSSOverlay: false,
  editCssOverlayName: null,

  flash: Ember.inject.service(),

  journalSelected: Ember.computed('journal', function() {
    return Ember.isPresent(this.get('journal'));
  }),

  actions: {
    showSaveMessage() {
      this.get('flash').displayRouteLevelMessage('success', 'Successfully Saved');
    },

    saveCSS(key, value) {
      this.set('journal.' + key + 'Css', value);
      this.get('journal').save().then(() => {
        this.send('showSaveMessage');
      });
    },

    editCSS(type) {
      this.setProperties({
        showEditCSSOverlay: true,
        css: this.get(`journal.${type}Css`),
        editCssOverlayName: 'edit-journal-' + type + '-css',
      });
    },

    hideEditCSSOverlay() {
      this.set('showEditCSSOverlay', false);
    }
  }
});
