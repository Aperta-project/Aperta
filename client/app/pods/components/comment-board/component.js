import Ember from 'ember';
const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['comment-board'],
  comments: [],
  commentsToShow: 5,
  commentSort: ['createdAt:desc'],
  sortedComments: computed.sort('comments', 'commentSort'),

  firstComments: computed('sortedComments', function() {
    return this.get('sortedComments').slice(0, 5);
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
      if(Ember.isEmpty(text)) { return; }
      this.attrs.postComment(text);
    }
  }
});
