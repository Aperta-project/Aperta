import Ember from 'ember';

export default Ember.Component.extend({
  viewing: null, //Snapshots are passed in
  comparing: null,

  isAuthor: Ember.computed.equal('viewing.name', 'author')
});

