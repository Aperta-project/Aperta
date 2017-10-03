import { test, moduleForComponent } from 'ember-qunit';
// import wait from 'ember-test-helpers/wait';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import wait from 'ember-test-helpers/wait';
import stubRouteAction from 'tahi/tests/helpers/stub-route-action';
import Ember from 'ember';


let paper, showActivity;
const template = hbs`
  <div id="mobile-nav"></div>
  {{paper-control-bar paper=paper tab="manuscript" showActivity=showActivity}}
`;

moduleForComponent('paper-control-bar', 'Integration | Component | Paper Control Bar', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    let routeActions = {
      showOrRaiseDiscussions(arg) {
        return Ember.RSVP.resolve({arg});
      }
    };
    stubRouteAction(this.container, routeActions);
    $.mockjax({
      type: 'GET',
      url: '/api/notifications/',
      status: 200,
      responseText: {}
    });
    paper = FactoryGuy.make('paper');
    this.set('paper', paper);
    showActivity = function() {};
    this.set('showActivity', showActivity);
  },
  afterEach() {
    $.mockjax.clear();
  }
});


test('can manage workflow, correspondence enabled, all icons show', function(assert) {
  FactoryGuy.make('feature-flag', {id: 1, name: 'CORRESPONDENCE', active: true});
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('#nav-correspondence').length, 1);
    assert.equal(this.$('#nav-workflow').length, 1);
    assert.equal(this.$('#nav-manuscript').length, 1);
  });
});

test('can manage workflow, correspondence disabled, no correspondence icon', function(assert) {
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('#nav-correspondence').length, 0);
    assert.equal(this.$('#nav-workflow').length, 1);
    assert.equal(this.$('#nav-manuscript').length, 1);
  });
});

test('can not manage workflow, correspondence enabled, no nav icons', function(assert) {
  const can = FakeCanService.create();
  this.register('service:can', can.asService());

  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('#nav-correspondence').length, 0);
    assert.equal(this.$('#nav-workflow').length, 0);
    assert.equal(this.$('#nav-manuscript').length, 0);
  });
});

test('can view recent activity, sees recent activity nav icon', function(assert) {
  const can = FakeCanService.create().allowPermission('view_recent_activity', paper);
  this.register('service:can', can.asService());

  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('#nav-recent-activity').length, 1);
  });
});

test('can not view recent activity, no recent activity nav icon', function(assert) {
  const can = FakeCanService.create();
  this.register('service:can', can.asService());

  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('#nav-recent-activity').length, 0);
  });
});
