/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
