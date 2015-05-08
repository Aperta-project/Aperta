import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  commenter: DS.belongsTo('user'),
  commentLook: DS.belongsTo('comment-look'),
  task: DS.belongsTo('task', { polymorphic: true }),

  body: DS.attr('string'),
  createdAt: DS.attr('date'),
  entities: DS.attr(),

  isUnread() {
    let commentLook = this.get('commentLook');
    if (commentLook) {
      return Ember.isEmpty(commentLook.get('readAt'));
    }
  },

  markRead() {
    this.set('commentLook.readAt', new Date());
    this.get('commentLook').save();
  }
});
