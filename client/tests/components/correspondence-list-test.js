import { test, moduleForComponent } from 'ember-qunit';
// import wait from 'ember-test-helpers/wait';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import wait from 'ember-test-helpers/wait';
import formatDate from 'tahi/lib/format-date';


moduleForComponent('correspondence', 'Integration | Component | Correspondence', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    $.mockjax({
      type: 'GET',
      url: '/api/notifications/',
      status: 200,
      responseText: {}
    });
  },

  afterEach() {
    $.mockjax.clear();
  }
});

let template = hbs`
  <div id="mobile-nav"></div>
  {{correspondence-list model=correspondence paper=paper}}
`;

test('can manage workflow, list appears', function(assert) {
  let paper = FactoryGuy.make('paper', { publishingState: 'submitted', firstSubmittedAt: '2016-09-28T13:54:58.028Z'});
  let correspondence = FactoryGuy.make('correspondence', { paper: paper });
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.set('correspondence', [correspondence]);
  this.set('paper', paper);
  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('.correspondence-table').length, 1);
    assert.equal(this.$('tbody').length, 1);
    assert.textPresent('tr:last td:nth-child(1)', formatDate(correspondence.get('sentAt'), {}));
    assert.textPresent('tr:last td:nth-child(2)', correspondence.get('subject'));
    assert.textPresent('tr:last td:nth-child(3)', correspondence.get('recipient'));
    assert.textPresent('tr:last td:nth-child(4)', 'v0.0 rejected');
    assert.textPresent('tr:last td:nth-child(5)', correspondence.get('sender'));
    assert.textPresent('.correspondence-table > p', 'Correspondence sent before February 1, 2017 is not available for display.');
  });
});

test('can manage workflow, list appears for manually created correspondence', function(assert) {
  let paper = FactoryGuy.make('paper');
  let correspondence = FactoryGuy.make('correspondence', 'externalCorrespondence', { paper: paper });
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.set('correspondence', [correspondence]);
  this.set('paper', paper);
  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('.correspondence-table .most-recent-activity').length, 0);
    assert.equal(this.$('.correspondence-table').length, 1);
    assert.equal(this.$('tbody').length, 1);
    assert.textPresent('tr:last td:nth-child(1)', formatDate(correspondence.get('sentAt'), {}));
    assert.textPresent('tr:last td:nth-child(2)', correspondence.get('subject'));
    assert.textPresent('tr:last td:nth-child(3)', correspondence.get('recipient'));
    assert.textPresent('tr:last td:nth-child(4)', 'Unavailable');
    assert.textPresent('tr:last td:nth-child(5)', correspondence.get('sender'));
    assert.equal(this.$('.correspondence-table > p').length, 0);
  });
});

test('can not manage workflow, list is hidden', function(assert) {
  let paper = FactoryGuy.make('paper');
  const can = FakeCanService.create();
  this.register('service:can', can.asService());

  this.set('paper', paper);
  this.render(template);
  return wait().then(() => {
    assert.equal(this.$('.correspondence-table').length, 0);
  });
});

test('correspondence with activities show the activity atop the entry', function(assert) {
  let paper = FactoryGuy.make('paper');
  let correspondence = FactoryGuy.make('correspondence', 'externalCorrespondence', {
    activities: [['correspondence.created', 'Jim', '1992-3-4']],
    paper: paper
  });
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.set('correspondence', [correspondence]);
  this.set('paper', paper);
  this.render(template);

  return wait().then(() => {
    assert.textPresent('.correspondence-table .most-recent-activity', 'Added by Jim');
  });
});
