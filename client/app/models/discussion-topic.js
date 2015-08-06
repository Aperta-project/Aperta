import DS from 'ember-data';

export default DS.Model.extend({
  discussionReplies: DS.hasMany('discussion-reply', {async: true}),
  discussionParticipants: DS.hasMany('discussion-participant', {
    async: false
  }),

  paperId: DS.attr('string'),
  title: DS.attr('string'),
  createdAt: DS.attr('date')
});
