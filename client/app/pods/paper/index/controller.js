import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, Discussions, {
  restless: Ember.inject.service('restless'),

  //sent by paper-new on creation, used to show submission process 1st view
  queryParams: ['firstView'],

  isGradualEngagement: Ember.computed.equal('model.gradualEngagement', true),

  submissionProcessDisplay: Ember.computed('showSubmissionProcess', function(){
    return (this.get('showSubmissionProcess')) ? 'block' : 'none';
  }),

  showSubmissionProcess: Ember.computed('model', 'firstView', 'isGradualEngagement', function() {
    if (!this.get('isGradualEngagement')) return false;

    if (this.get('firstView') === 'true' ) {
      this.set('firstView', undefined); //removes from url
      return true;
    }
  }),

  activityIsLoading: false,
  showActivityOverlay: false,
  activityFeed: null,

  showCollaboratorsOverlay: false,

  actions: {
    toggleSubmissionProcess(){
      Ember.$('#submission-process').slideToggle(300);
    },

    hideActivityOverlay() {
      this.set('showActivityOverlay', false);
    },

    showActivity(type) {
      this.set('activityIsLoading', true);
      this.set('showActivityOverlay', true);
      const url = `/api/papers/${this.get('model.id')}/activity/${type}`;

      this.get('restless').get(url).then((data)=> {
        this.setProperties({
          activityIsLoading: false,
          activityFeed: Utils.deepCamelizeKeys(data.feeds)
        });
      });
    },

    showCollaboratorsOverlay() {
      this.set('showCollaboratorsOverlay', true);
    },

    hideCollaboratorsOverlay() {
      this.set('showCollaboratorsOverlay', false);
    }
  }
});
