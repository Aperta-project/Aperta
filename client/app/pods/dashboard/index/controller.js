import Ember from 'ember';

export default Ember.Controller.extend({
  papers: [],
  unreadComments: [],
  pendingInvitations: Ember.computed('currentUser.invitedInvitations', function() {
    return this.get('currentUser.invitedInvitations');
  }),

  hasPapers:         Ember.computed.notEmpty('papers'),
  hasActivePapers:   Ember.computed.notEmpty('activePapers'),
  hasInactivePapers: Ember.computed.notEmpty('inactivePapers'),
  activePageNumber:   1,
  inactivePageNumber: 1,
  relatedAtSort: ['relatedAtDate:desc'],
  updatedAtSort: ['updatedAt:desc'],
  sortedNonDraftPapers:   Ember.computed.sort('activeNonDrafts', 'relatedAtSort'),
  sortedDraftPapers:      Ember.computed.sort('activeDrafts', 'updatedAtSort'),
  sortedInactivePapers:   Ember.computed.sort('inactivePapers', 'updatedAtSort'),
  activeDrafts:           Ember.computed.filterBy('activePapers', 'publishingState', 'unsubmitted'),
  activeNonDrafts:        Ember.computed.filter('activePapers', function(paper) {
                            return paper.get('publishingState') !== 'unsubmitted';
                          }),
  activePapers:           Ember.computed.filterBy('papers', 'active', true),
  inactivePapers:         Ember.computed.filterBy('papers', 'active', false),

  totalActivePaperCount: Ember.computed('papers.length', function() {
    let numPapersFromServer       = this.store.metadataFor('paper').total_active_papers;
    let numDashboardPapersInStore = this.get('activePapers.length');

    return numDashboardPapersInStore > numPapersFromServer ? numDashboardPapersInStore : numPapersFromServer;
  }),

  canLoadMoreActive: Ember.computed('activePageNumber', function() {
    return this.get('activePageNumber') !== this.store.metadataFor('paper').total_active_pages;
  }),

  canLoadMoreInactive: Ember.computed('inactivePageNumber', function() {
    return this.get('inactivePageNumber') !== this.store.metadataFor('paper').total_inactive_pages;
  }),

  actions: {
    loadMoreActivePapers() {
      this.store.find('paper', { page_number: this.get('activePageNumber') + 1 }).then(()=> {
        this.incrementProperty('activePageNumber');
      });
    },
    loadMoreInactivePapers() {
      this.store.find('paper', { page_number: this.get('inactivePageNumber') + 1 }).then(()=> {
        this.incrementProperty('inactivePageNumber');
      });
    }
  }
});
