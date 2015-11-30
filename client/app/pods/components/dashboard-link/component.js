import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  unreadCommentsCount: Ember.computed.alias('model.commentLooks.length'),

  status: Ember.computed('model.publishingState', function() {
    if (this.get('model.publishingState') === 'unsubmitted') {
      return 'DRAFT';
    } else {
      return this.get('model.publishingState').replace(/_/g, ' ').toUpperCase();
    }
  }),

  roles: Ember.computed('model.roles', function() {
    if (this.get('model.roles').indexOf('My Paper') > -1) {
      return 'Author';
    } else {
      return this.get('model.roles');
    }
  }),

  paperLinkId: Ember.computed(function(){
    return "view-paper-" + this.get('model.id');
  }),
});
