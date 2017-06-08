import Ember from 'ember';
import pluralizeString from 'tahi/lib/pluralize-string';

export default Ember.Controller.extend({
  restless: Ember.inject.service('restless'),

  papers: [],
  unreadComments: [],
  invitationsInvited: Ember.computed.alias('currentUser.invitationsInvited'),
  invitationsNeedsUserUpdate: Ember.computed.alias('currentUser.invitationsNeedsUserUpdate'),
  invitationsPendingDecline: Ember.computed.filter(
    'invitationsNeedsUserUpdate',
    function(invitation) {
      return invitation.get('declined') && invitation.get('pendingFeedback');
    }
  ),

  hasPapers:         Ember.computed.notEmpty('papers'),
  hasActivePapers:   Ember.computed.notEmpty('activePapers'),
  hasInactivePapers: Ember.computed.notEmpty('inactivePapers'),
  activePageNumber:   1,
  inactivePageNumber: 1,
  activePapersVisible: true,
  inactivePapersVisible: true,
  invitationsLoading: false,
  relatedAtSort: ['relatedAtDate:desc'],
  updatedAtSort: ['updatedAt:desc'],
  sortedNonDraftPapers: Ember.computed.sort('activeNonDrafts', 'relatedAtSort'),
  sortedDraftPapers:    Ember.computed.sort('activeDrafts', 'updatedAtSort'),
  sortedInactivePapers: Ember.computed.sort('inactivePapers', 'updatedAtSort'),
  activeDrafts:         Ember.computed.filterBy(
                          'activePapers', 'publishingState', 'unsubmitted'
                        ),
  activeNonDrafts:      Ember.computed.filter('activePapers', function(paper) {
                          return paper.get('publishingState') !== 'unsubmitted';
                        }),
  activePapers:         Ember.computed.filterBy('papers', 'active', true),
  inactivePapers:       Ember.computed.filterBy('papers', 'active', false),

  totalActivePaperCount: Ember.computed.alias('activePapers.length'),

  totalInactivePaperCount: Ember.computed.alias('inactivePapers.length'),
  activeManuscriptsHeading: Ember.computed('totalActivePaperCount', function() {
    return 'Active ' +
            pluralizeString('Manuscript', this.get('totalActivePaperCount')) +
            ' (' +
            this.get('totalActivePaperCount') +
            ')';
  }),
  inactiveManuscriptsHeading: Ember.computed('totalInactivePaperCount',
    function() {
      const count = this.get('totalInactivePaperCount');
      return 'Inactive ' + pluralizeString('Manuscript', count) +
             ' (' + this.get('totalInactivePaperCount') + ')';
    }
  ),

  showNewManuscriptOverlay: false,

  hideInvitationsOverlay() {
    this.set('showInvitationsOverlay', false);
  },

  actions: {
    toggleActiveContainer() {
      this.toggleProperty('activePapersVisible');
    },

    toggleInactiveContainer() {
      this.toggleProperty('inactivePapersVisible');
    },

    showInvitationsOverlay() {
      this.set('showInvitationsOverlay', true);
    },

    hideInvitationsOverlay() {
      this.get('invitationsPendingDecline').forEach((invitation) => {
        invitation.decline();
      });
      this.hideInvitationsOverlay();
    },

    declineInvitation(invitation) {
      return invitation.decline();
    },

    acceptInvitation(invitation) {
      this.set('invitationsLoading', true);
      return this.get('restless').putUpdate(invitation, '/accept').then(()=> {
        this.hideInvitationsOverlay();
        this.transitionToRoute('paper.index', invitation.get('paperShortDoi')).then(() => {
          let msg = `Thank you for agreeing to review for ${invitation.get('journalName')}.`;
          this.flash.displayRouteLevelMessage('success', msg);
        });
      }, () => { this.set('invitationsLoading', false); });
    },

    showNewManuscriptOverlay() {
      const journals = this.store.findAll('journal');
      const paper = this.store.createRecord('paper', {
        journal: null,
        paperType: null,
        editable: true,
        body: ''
      });

      this.setProperties({
        journals: journals,
        newPaper: paper,
        journalsLoading: true
      });

      journals.then(()=> { this.set('journalsLoading', false); });

      this.set('showNewManuscriptOverlay', true);
    },

    hideNewManuscriptOverlay() {
      this.set('showNewManuscriptOverlay', false);
    },

    newManuscriptCreated(manuscript) {
      this.setProperties({
        showNewManuscriptOverlay: false,
        isUploading: false
      });

      this.transitionToRoute('paper.index', manuscript, {
        queryParams: { firstView: 'true' }
      });
    }
  }
});
