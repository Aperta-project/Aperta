import Ember from 'ember';

export default Ember.Component.extend({
  cardVersions: null,
  dateSort: [ 'isPublished', 'publishedAt:desc'],
  sortedVersions: Ember.computed.sort('cardVersions', 'dateSort')
});
