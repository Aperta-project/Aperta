import Ember from 'ember';
import startApp from '../helpers/start-app';
import { test, moduleFor } from 'ember-qunit';
import FactoryGuy from "ember-data-factory-guy";
import TestHelper from "ember-data-factory-guy/factory-guy-test-helper";

moduleFor('controller:overlays/paper-submit', 'SubmitPaperController', {
  beforeEach: function() {
    startApp();
  }
});
