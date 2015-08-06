import Ember from 'ember';
const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['comment-board'],
  comments: [],
  commentsToShow: 5,
  commentSort: ['createdAt:desc'],
  sortedComments: computed.sort('comments', 'commentSort'),

  firstComments: computed.filter('sortedComments', function(comment, index) {
    return index < 5;
  }),

  showingAllComments: computed('comments.length', function() {
    return this.get('comments.length') <= this.get('commentsToShow');
  }),

  omittedCommentsCount: computed('comments.length', function() {
    return this.get('comments.length') - this.get('commentsToShow');
  }),

  actions: {
    showAllComments() {
      this.set('showingAllComments', true);
    },

    postComment(text) {
      this.sendAction('postComment', text);
    }
  }
});
