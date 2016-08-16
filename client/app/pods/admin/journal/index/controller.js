import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Controller.extend(ValidationErrorsMixin, {
  pdfCssSaveStatus: '',
  manuscriptCssSaveStatus: '',
  canDeleteManuscriptManagerTemplates:
    Ember.computed.gt('model.manuscriptManagerTemplates.length', 1),

  adminJournalUsers: null,

  showEditTaskTypesOverlay: false,

  showEditCSSOverlay: false,
  editCssOverlayName: null,

  resetSearch() {
    this.set('adminJournalUsers', null);
    return this.set('placeholderText', null);
  },

  actions: {
    saveCSS(key, value) {
      this.set('model.' + key + 'Css', value);
      this.get('model').save().then(()=> {
        this.set(key + 'CssSaveStatus', 'Saved');
      });
    },

    addMMTemplate() {
      this.transitionTo('admin.journal.manuscript_manager_template.new');
    },

    destroyMMTemplate(template) {
      if (this.get('canDeleteManuscriptManagerTemplates')) {
        return template.destroyRecord();
      }
    },

    searchUsers() {
      this.resetSearch();

      const params = {
        query: this.get('searchQuery'),
        journal_id: this.get('model.id')
      };

      this.store.query('admin-journal-user', params).then((users)=> {
        this.set('adminJournalUsers', users);
        if(Ember.isEmpty(this.get('adminJournalUsers'))) {
          this.set('placeholderText', 'No matching users found');
        }
      });
    },

    resetSaveStatuses: function() {
      this.setProperties({
        pdfCssSaveStatus: '',
        manuscriptCssSaveStatus: ''
      });
    },

    showEditTaskTypesOverlay() {
      this.set('showEditTaskTypesOverlay', true);
    },

    hideEditTaskTypesOverlay() {
      this.set('showEditTaskTypesOverlay', false);
    },

    editCSS(type) {
      this.setProperties({
        showEditCSSOverlay: true,
        css: this.get('model.' + type + 'Css'),
        editCssOverlayName: 'edit-journal-' + type + '-css',
      });
    },

    hideEditCSSOverlay() {
      this.set('showEditCSSOverlay', false);
    }
  }
});
