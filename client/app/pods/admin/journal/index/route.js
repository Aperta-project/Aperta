import Ember from 'ember';

export default Ember.Route.extend({
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('doiStartNumberEditable', Ember.isEmpty(model.get('lastDoiIssued')));
    this.fetchAdminJournalUsers(model.get('id'));
  },

  deactivate() {
    this.set('controller.adminJournalUsers', null);
    return this.set('controller.doiEditState', false);
  },

  fetchAdminJournalUsers(journalId) {
    return this.store.find('AdminJournalUser', {
      journal_id: journalId
    }).then((users)=> {
      this.set('controller.adminJournalUsers', users);
    });
  },

  actions: {
    openEditOverlay(key) {
      this.controllerFor('overlays/adminJournal').setProperties({
        model: this.modelFor('admin/journal/index'),
        propertyName: key
      });

      this.send('openOverlay', {
        template: 'overlays/admin-journal-' + (key.dasherize()),
        controller: 'overlays/adminJournal'
      });
    },

    editEPubCSS() {
      this.send('openEditOverlay', 'epubCss');
    },

    editPDFCSS() {
      this.send('openEditOverlay', 'pdfCss');
    },

    editManuscriptCSS() {
      this.send('openEditOverlay', 'manuscriptCss');
    },

    editTaskTypes() {
      this.send('openOverlay', {
        template: 'overlays/editTaskTypes',
        controller: 'overlays/editTaskTypes',
        model: this.modelFor('admin/journal/index')
      });
    }
  }
});
