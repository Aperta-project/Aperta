import DS from 'ember-data';

export default DS.Model.extend({
  key: DS.attr('string'),
  settingKlass: DS.attr('string'),
  settingName: DS.attr('string'),
  global: DS.attr('boolean')
});
