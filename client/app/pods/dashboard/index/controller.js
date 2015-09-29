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
  activePapersVisible: true,
  inactivePapersVisible: true,
  relatedAtSort: ['relatedAtDate:desc'],
  updatedAtSort: ['updatedAt:desc'],
  sortedNonDraftPapers: Ember.computed.sort('activeNonDrafts', 'relatedAtSort'),
  sortedDraftPapers:    Ember.computed.sort('activeDrafts', 'updatedAtSort'),
  sortedInactivePapers: Ember.computed.sort('inactivePapers', 'updatedAtSort'),
  activeDrafts:         Ember.computed.filterBy('activePapers', 'publishingState', 'unsubmitted'),
  activeNonDrafts:      Ember.computed.filter('activePapers', function(paper) {
                          return paper.get('publishingState') !== 'unsubmitted';
                        }),
  activePapers:         Ember.computed.filterBy('papers', 'active', true),
  inactivePapers:       Ember.computed.filterBy('papers', 'active', false),

  totalActivePaperCount: Ember.computed.alias('activePapers.length'),

  totalInactivePaperCount: Ember.computed.alias('inactivePapers.length'),

  actions: {
    toggleActiveContainer() {
      this.toggleProperty('activePapersVisible');
    },
    toggleInactiveContainer() {
      this.toggleProperty('inactivePapersVisible');
    }
  }
});
