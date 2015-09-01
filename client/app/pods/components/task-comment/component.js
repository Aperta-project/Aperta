import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',
  classNameBindings: [':message-comment', 'unread'],

  // attrs:
  // comment

  // props:
  unread: false,

  highlightedBody: Ember.computed('comment.body', function() {
    return this.highlightBody(
      this.get('comment.body'),
      this.get('comment.entities.user_mentions')
    );
  }),

  setUnreadState: Ember.on('init', function() {
    Ember.run.schedule('afterRender', ()=> {
      let commentLook = this.get('comment.commentLook');
      if(Ember.isPresent(commentLook)) {
        this.set('unread', true);
        commentLook.destroyRecord();
      }
    });
  }),

  highlightBody(body, mentions) {
    let first, i, j, last, len, len1, mention, mentionString, regex;
    if (!mentions) { return body; }

    let mentionStrings = [];

    for (i = 0, len = mentions.length; i < len; i++) {
      mention = mentions[i];
      first = mention.indices[0];
      last = mention.indices[1];
      mentionString = body.slice(first, last);
      mentionStrings.push(mentionString);
    }

    for (j = 0, len1 = mentionStrings.length; j < len1; j++) {
      mention = mentionStrings[j];
      regex = new RegExp('(' + mention + ')');
      body = body.replace(regex, '<strong>$1</strong>');
    }

    return body;
  }
});
