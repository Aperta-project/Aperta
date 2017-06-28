import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('registered-setting', {
  default: {
    key: 'TaskTemplate:TahiStandardTasks::SimilarityCheckTask',
    settingKlass: 'Setting::IthenticateAutomation',
    settingName: 'ithenticate_automation',
    global: 'true'
  }
});
