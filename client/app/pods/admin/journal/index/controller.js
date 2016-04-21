import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Controller.extend(ValidationErrorsMixin, {
  epubCssSaveStatus: '',
  pdfCssSaveStatus: '',
  manuscriptCssSaveStatus: '',
  doiEditState: false,
  doiStartNumberEditable: true,
  canDeleteManuscriptManagerTemplates:
    Ember.computed.gt('model.manuscriptManagerTemplates.length', 1),

  epubCoverUploadUrl: Ember.computed('model.id', function() {
    const id = this.get('model.id');
    return '/api/admin/journals/' + id + '/upload_epub_cover';
  }),

  adminJournalUsers: null,
  epubCoverUploading: false,

  showEditTaskTypesOverlay: false,

  showEditCSSOverlay: false,
  editCssOverlayName: null,

  resetSearch() {
    this.set('adminJournalUsers', null);
    return this.set('placeholderText', null);
  },

  formattedDOI: Ember.computed(
    'doiPublisherPrefix', 'doiJournalPrefix', 'firstDoiNumber', function() {
      if (this.get('doiInvalid')) { return ''; }

      const publisher = this.get('doiPublisherPrefix');
      const journal = this.get('doiJournalPrefix');
      const start = this.get('firstDoiNumber');
      const dot = Ember.isEmpty(journal) ? '' : '.';
      return publisher + '/' + journal + dot + start;
    }
  ),

  doiInvalid: Ember.computed('doiPublisherPrefix', 'firstDoiNumber', function() {
    const noPubPrefix = Ember.isEmpty(this.get('doiPublisherPrefix'));
    const noLastDoi = Ember.isEmpty(this.get('firstDoiNumber'));
    const invalid = this.get('doiStartNumberInvalid');

    return noPubPrefix || noLastDoi || invalid;
  }),

  doiStartNumberInvalid: Ember.computed('firstDoiNumber', function() {
    return !$.isNumeric(this.get('firstDoiNumber')) &&
           !Ember.isEmpty(this.get('doiStartNumber'));
  }),

  actions: {
    saveCSS(key, value) {
      this.set('model.' + key + 'Css', value);
      this.get('model').save().then(()=> {
        this.set(key + 'CssSaveStatus', 'Saved');
      });
    },

    assignOldRoleToUser(oldRoleID, user) {
      const oldRole = this.store.getById('oldRole', oldRoleID);

      return this.store.createRecord('userRole', {
        user: user,
        oldRole: oldRole
      }).save();
    },

    addRole() {
      this.get('model.oldRoles').addObject(this.store.createRecord('old-role'));
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

      this.store.find('AdminJournalUser', params).then((users)=> {
        this.set('adminJournalUsers', users);
        if(Ember.isEmpty(this.get('adminJournalUsers'))) {
          this.set('placeholderText', 'No matching users found');
        }
      });
    },

    epubCoverUploading() {
      this.set('epubCoverUploading', true);
    },

    epubCoverUploaded(data) {
      this.set('epubCoverUploading', false);
      const journal = data.admin_journal;

      this.setProperties({
        epubCoverUrl: journal.epub_cover_url,
        epubCoverFileName: journal.epub_cover_file_name,
        epubCoverUploadedAt: journal.epub_cover_uploaded_at
      });
    },

    resetSaveStatuses: function() {
      this.setProperties({
        epubCssSaveStatus: '',
        pdfCssSaveStatus: '',
        manuscriptCssSaveStatus: ''
      });
    },

    editDOI() {
      this.set('doiEditState', true);
    },

    cancelDOI() {
      this.get('model').rollback();
      this.set('doiEditState', false);
    },

    saveDOI() {
      if (this.get('doiInvalid')) { return; }

      this.set('doiStartNumberEditable', false);
      this.get('model').save().then(()=> {
        this.set('doiEditState', false);
        this.clearAllValidationErrors();
      }, (response)=> {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    assignOldRole(oldRoleID, user) {
      const userRole = this.store.createRecord('userRole', {
        user: user,
        oldRole: this.store.getById('oldRole', oldRoleID)
      });

      return userRole.save()['catch'](function() {
        userRole.transitionTo('created.uncommitted');
        return userRole.deleteRecord();
      });
    },

    removeOldRole(userRoleId) {
      return this.store.getById('userRole', userRoleId).destroyRecord();
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
