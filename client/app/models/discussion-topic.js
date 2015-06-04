import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  replies: DS.hasMany('discussion-reply'),
  participants: DS.hasMany('user'),

  paperId: DS.attr('number'),
  title: DS.attr('string')
});
