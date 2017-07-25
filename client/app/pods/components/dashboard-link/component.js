import Ember from 'ember';
import formatDate from 'tahi/lib/format-date';

export default Ember.Component.extend({
  attributeBindings: ['data-test-id'],
  'data-test-id': Ember.computed('model', function(){
    let paperId = this.get('model.id');
    return `dashboard-paper-${paperId}`;
  }),
  tagName: 'tr',
  unreadCommentsCount: Ember.computed.reads('model.commentLooks.length'),
  dueDate: Ember.computed.reads('model.reviewDueAt'),

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

  reviewDueMessage: Ember.computed('model.roles', 'model.reviewDueAt', function() {
    if (this.get('model.roles') == 'Reviewer') {
      return 'Your review is due ' + formatDate(this.get('model.reviewDueAt'), { format: 'MMMM DD' });
    } else {
      return "";
    }
  }),

  originallyDueMessage: Ember.computed('model.roles','model.reviewDueAt', function() {
    if (this.get('model.roles') == 'Reviewer' && !Ember.isEmpty(this.get('model.reviewOriginallyDueAt'))) {
      return 'Originally due ' + formatDate(this.get('model.reviewOriginallyDueAt'), { format: 'MMMM DD' });
    } else {
      return "";
    }
  }),

  paperLinkId: Ember.computed(function(){
    return "view-paper-" + this.get('model.id');
  }),
});
