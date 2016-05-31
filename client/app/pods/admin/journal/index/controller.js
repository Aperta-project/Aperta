import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Controller.extend(ValidationErrorsMixin, {
  pdfCssSaveStatus: '',
  manuscriptCssSaveStatus: '',
  doiEditState: false,
  doiStartNumberEditable: true,
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

  formattedDOI: Ember.computed(
    'doiPublisherPrefix', 'doiJournalPrefix', 'lastDoiIssued', function() {
      if (this.get('doiInvalid')) { return ''; }

      const publisher = this.get('doiPublisherPrefix');
      const journal = this.get('doiJournalPrefix');
      const start = this.get('lastDoiIssued');
      const dot = Ember.isEmpty(journal) ? '' : '.';
      return publisher + '/' + journal + dot + start;
    }
  ),

  doiInvalid: Ember.computed('doiPublisherPrefix', 'lastDoiIssued', function() {
    const noPubPrefix = Ember.isEmpty(this.get('doiPublisherPrefix'));
    const noLastDoi = Ember.isEmpty(this.get('lastDoiIssued'));
    const invalid = this.get('doiStartNumberInvalid');

    return noPubPrefix || noLastDoi || invalid;
  }),

  doiStartNumberInvalid: Ember.computed('lastDoiIssued', function() {
    return !$.isNumeric(this.get('lastDoiIssued')) &&
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

    resetSaveStatuses: function() {
      this.setProperties({
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
