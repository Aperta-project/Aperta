import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, Discussions, {
  correspondence: Ember.computed.alias('model'),
  sortedSentAt: Ember.computed.sort('correspondence', 'sortDefinition'),
  sortDefinition: ['sentAt:desc'],
  subRouteName: 'correspondence'
});
