import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['comment-board'],
  editing: false,
  comments: [],
  commentBody: '',
  commentsToShow: 5,
  commentSort: ['createdAt:desc'],
  sortedComments: Ember.computed.sort('comments', 'commentSort'),

  firstComments: Ember.computed.filter('sortedComments', function(comment, index) {
    return index < 5;
  }),

  setupFocus: function() {
    this.$('.new-comment-field').on('focus', ()=> {
      this.set('editing', true);
    });
  }.on('didInsertElement'),

  showingAllComments: function() {
    return this.get('comments.length') <= this.get('commentsToShow');
  }.property('comments.length'),

  omittedCommentsCount: function() {
    return this.get('comments.length') - this.get('commentsToShow');
  }.property('comments.length'),

  actions: {
    showAllComments() {
      this.set('showingAllComments', true);
    },

    postComment() {
      this.sendAction('postComment', this.get('commentBody'));
      this.send('clearComment');
    },

    clearComment() {
      this.set('commentBody', '');
      this.set('editing', false);
    }
  }
});
