import DS from 'ember-data';

export default DS.Model.extend({
  discussionReplies: DS.hasMany('discussion-reply', {async: true}),
  participants: DS.hasMany('user'),

  paperId: DS.attr('string'),
  title: DS.attr('string')
});
