import Ember from 'ember';

export default Ember.Component.extend({
  attributeBindings: ['id'],
  id: Ember.computed('model', function(){
    let paperId = this.get('model.id');
    return `dashboard-paper-${paperId}`;
  }),
  tagName: 'tr',
  unreadCommentsCount: Ember.computed.alias('model.commentLooks.length'),

  status: Ember.computed('model.publishingState', function() {
    if (this.get('model.publishingState') === 'unsubmitted') {
      return 'DRAFT';
    } else {
      return this.get('model.publishingState').replace(/_/g, ' ').toUpperCase();
    }
  }),

  oldRoles: Ember.computed('model.oldRoles', function() {
    if (this.get('model.oldRoles').indexOf('My Paper') > -1) {
      return 'Author';
    } else {
      return this.get('model.oldRoles');
    }
  }),

  paperLinkId: Ember.computed(function(){
    return "view-paper-" + this.get('model.id');
  }),
});
