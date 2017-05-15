import Ember from 'ember';
import Resolver from './resolver';
import loadInitializers from 'ember-load-initializers';
import config from './config/environment';

let App;

Ember.MODEL_FACTORY_INJECTIONS = true;

// uncomment and navigate to invoke or invokeWithOnError and look
// at the errorRecordedForStack property to get stack traces for the run loop
// Ember.run.backburner.DEBUG = true;

App = Ember.Application.extend({
  modulePrefix: config.modulePrefix,
  podModulePrefix: config.podModulePrefix,
  //  Uncomment for helpful debugging when you see a blank Ember page
  //  LOG_TRANSITIONS_INTERNAL: true,
  Resolver
});

loadInitializers(App, config.modulePrefix);

export default App;
