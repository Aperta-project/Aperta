import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',
  classNameBindings: [':message-comment', 'unread'],

  // props:
  unread: false,

  setUnreadState: Ember.on('init', function() {
    Ember.run.schedule('afterRender', ()=> {
      let commentLook = this.get('comment.commentLook');
      if(Ember.isPresent(commentLook)) {
        this.set('unread', true);
        commentLook.destroyRecord();
      }
    });
  }),
});
