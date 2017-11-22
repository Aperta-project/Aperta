import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('correspondence', {
  default: {
    date: '2014-09-28T13:54:58.028Z',
    sentAt: 'Thu, 20 Jul 2017 14:58:40 UTC +00:00',
    subject: 'Thank you for submitting your manuscript to PLOS Abominable Snowman',
    body: 'This is a very long body message~~~~',
    recipient: 'john.doe@example.com',
    sender: 'joe@example.com',
    manuscriptVersion: 'v0.0',    
    manuscriptStatus: 'rejected',
    attachments: FactoryGuy.hasMany('correspondence-attachment', 2)    
  },

  traits: {
    externalCorrespondence: {
      external: true,
      date: '2014-09-28T13:54:58.028Z',
      sentAt: 'Thu, 20 Jul 2017 14:58:40 UTC +00:00',
      subject: 'Thank you for submitting your manuscript to PLOS Abominable Snowman',
      body: 'This is a very long body message~~~~',
      recipient: 'john.doe@example.com',
      sender: 'joe@example.com',
      manuscriptVersion: null,
      manuscriptStatus: null
    } 
  }  
});
