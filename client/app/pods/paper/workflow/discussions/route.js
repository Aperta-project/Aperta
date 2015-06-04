import Ember from 'ember';

export default Ember.Route.extend({
  // model() {
  //   return this.store.find('paper-discussion', {
  //     paper_id: this.modelFor('paper').get('id')
  //   });
  // },

  model() {
    let payload = {
      discussion_topics: [{
        id: 1,
        reply_ids: [1],
        participant_ids: [12],
        paper_id: 13,
        title: 'This is a real topic, woooo!'
      }, {
        id: 2,
        reply_ids: [2],
        participant_ids: [12],
        paper_id: 13,
        title: 'Another topic, woooo!',
        unreadCount: 3
      }],

      discussion_replies: [{
        id: 1,
        topic_id: 1,
        replier_id: 12,
        body: 'This is a super important comment'
      }, {
        id: 2,
        topic_id: 2,
        replier_id: 12,
        body: 'This is a really, really important comment'
      }]
    };

    this.store.pushPayload(payload);

    return this.store.all('discussion-topic');
  },

  actions: {
    hideDiscussions() {
      this.transitionTo('paper.workflow');
    }
  }
});
