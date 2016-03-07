import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('paper', {
  default: {
    title: '',
    shortTitle: '',
    publishingState: 'unsubmitted',
    oldRoles: [],
    relatedAtDate: '2014-09-28T13:54:58.028Z',
    editable: true
  },

  paper_with_discussion: {
    title: '',
    shortTitle: '',
    publishingState: 'unsubmitted',
    oldRoles: [],
    relatedAtDate: '2014-09-28T13:54:58.028Z',
    editable: true,
    discussionTopics: [{
      id: 1,
      title: 'Tech Check Discussion',
      discussionReplies: [],
      discussionParticipants: []
    }]
  },

  traits: {

    withRoles: {
      oldRoles: ['participant']
    }

  }
});
