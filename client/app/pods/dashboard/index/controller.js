import Ember from 'ember';

export default Ember.Controller.extend({
  papers: [],
  invitations: [],
  unreadComments: [],
  pendingInvitations: Ember.computed.filterBy('invitations', 'state', 'invited'),
  hasPapers: Ember.computed.notEmpty('papers'),
  pageNumber: 1,
  relatedAtSort: ['relatedAtDate:desc'],
  sortedPapers: Ember.computed.sort('papers', 'relatedAtSort'),

  totalPaperCount: function() {
    let numPapersFromServer       = this.store.metadataFor('paper').total_papers;
    let numDashboardPapersInStore = this.get('papers.length');

    return numDashboardPapersInStore > numPapersFromServer ? numDashboardPapersInStore : numPapersFromServer;
  }.property('papers.length'),

  canLoadMore: function() {
    return this.get('pageNumber') !== this.store.metadataFor('paper').total_pages;
  }.property('pageNumber'),

  actions: {
    loadMorePapers() {
      this.store.find('paper', { page_number: this.get('pageNumber') + 1 }).then(()=> {
        this.incrementProperty('pageNumber');
      });
    }
  }
});
