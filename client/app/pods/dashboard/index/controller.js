import Ember from 'ember';
import pluralizeString from 'tahi/lib/pluralize-string';
import DS from 'ember-data';

export default Ember.Controller.extend({
  can: Ember.inject.service('can'),
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
  hasPostedPreprints: Ember.computed.notEmpty('preprints'),
  activePageNumber:   1,
  inactivePageNumber: 1,
  activePapersVisible: true,
  inactivePapersVisible: true,
  preprintsVisible: true,
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
  preprints: Ember.computed.filter('papers', function(paper) {
    return paper.get('preprintDashboard');
  }),

  totalActivePaperCount: Ember.computed.alias('activePapers.length'),

  totalInactivePaperCount: Ember.computed.alias('inactivePapers.length'),
  totalPreprintCount: Ember.computed.alias('preprints.length'),
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
  postedPreprintsHeading: Ember.computed('totalPreprintCount', function() {
    return `Preprints (${this.get('totalPreprintCount')})`;
  }),
  showNewManuscriptOverlay: false,

  hideInvitationsOverlay() {
    this.set('showInvitationsOverlay', false);
  },

  messagePerRole(role, journalName) {
    let msg;
    if (role === 'Reviewer') {
      msg = `Thank you for agreeing to review for ${journalName}.`;
    } else {
      msg = `Thank you for agreeing to be an ${role} on this ${journalName} manuscript.`;
    }
    this.flash.displayRouteLevelMessage('success', msg);
  },

  actions: {
    toggleActiveContainer() {
      this.toggleProperty('activePapersVisible');
    },

    toggleInactiveContainer() {
      this.toggleProperty('inactivePapersVisible');
    },

    togglePreprintContainer() {
      this.toggleProperty('preprintsVisible');
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
          let role = invitation.get('inviteeRole');
          let journalName = invitation.get('journalName');
          this.messagePerRole(role, journalName);
        });
      }).finally(() => { this.set('invitationsLoading', false); });
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

    // Set the "visible=" flag linked to an overlay to false. E.g., "showNewManuscriptOverlay"
    hideOverlay(name) {
      let flagName = 'show' + name + 'Overlay';
      this.set(flagName, false);
    },

    newManuscriptCreated(manuscript, template) {
      this.setProperties({
        showNewManuscriptOverlay: false,
        isUploading: false
      });

      if (template.is_preprint_eligible && template.task_names.includes('Preprint Posting')) {
        this.set('showPreprintOverlay', true);
      } else {
        this.transitionToRoute('paper.index', manuscript, {
          queryParams: { firstView: 'true' }
        });
      }
    },

    offerPreprintComplete() {
      this.send('hideOverlay', 'Preprint');
      let manuscript = this.get('newPaper');
      manuscript.reload();
      this.transitionToRoute('paper.index', manuscript, {
        queryParams: { firstView: 'true' }
      });
    }
  }
});
