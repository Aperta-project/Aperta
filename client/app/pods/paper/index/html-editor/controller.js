import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';
import Utils from 'tahi/services/utils';

export default Ember.Controller.extend(PaperBase, Discussions, {
  restless: Ember.inject.service('restless'),

  activityIsLoading: false,
  showActivityOverlay: false,
  activityFeed: null,

  actions: {
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
  }
});
