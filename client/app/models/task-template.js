import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  card: DS.belongsTo('card'),
  journalTaskType: DS.belongsTo('journal-task-type', { async: false }),
  phaseTemplate: DS.belongsTo('phase-template', { async: false }),
  position: DS.attr('number'),
  template: DS.attr(),
  title: DS.attr('string'),
  type: Ember.computed.readOnly('kind'),
  kind: Ember.computed.readOnly('journalTaskType.kind'),
  allSettings: DS.attr(),
  settings: Ember.computed('allSettings', function(){
    return Ember.A(this.get('allSettings')).map(function(setting) {
      return Ember.Object.create(setting);
    });
  }),
  settingsEnabled: DS.attr(),
  restless: Ember.inject.service(),
  settingComponents: Ember.computed('settings', function(){
    let settingMap = {
      ithenticate_automation: 'similarity-check-settings',
      review_duration_period: 'invite-reviewers-settings'
    };
    return this.get('settings').map(function(setting) {
      return settingMap[setting.get('name')];
    });
  }),
  updateSetting: function (settingName, settingValue) {
    const url = `/api/task_templates/${this.get('id')}/update_setting`;
    return this.get('restless').put(url, {name: settingName, value: settingValue}).then(() => {
      this.get('settings').findBy('name', settingName).set('value', settingValue);
    });
  }
});
