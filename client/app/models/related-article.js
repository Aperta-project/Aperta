import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: true }),
  linkedDOI: DS.attr('string'), // I might not work!
  linkedTitle: DS.attr('string'),
  additionalInfo: DS.attr('string'),
  sendManuscriptsTogether: DS.attr('boolean'),
  sendLinkToApex: DS.attr('boolean')
});
