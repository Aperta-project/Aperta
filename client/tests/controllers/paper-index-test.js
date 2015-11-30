import Ember from 'ember';
import startApp from '../helpers/start-app';
import { test, moduleFor } from 'ember-qunit';
moduleFor('controller:paper.index', 'PaperIndexController', {
  needs: ['controller:application', 'controller:paper'],
  beforeEach: function() {
    startApp();
    this.phase1 = Ember.Object.create({ position: 1 });
    this.phase2 = Ember.Object.create({ position: 2 });
    this.phase3 = Ember.Object.create({ position: 3 });
    this.phase4 = Ember.Object.create({ position: 4 });
    this.paper = Ember.Object.create({ title: 'test paper', phases: [] });
    return sinon.stub(jQuery, "ajax");
  },
  afterEach: function() {
    return jQuery.ajax.restore();
  }
});
