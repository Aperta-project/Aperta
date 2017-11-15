import { test, moduleForComponent } from 'ember-qunit';
import { make, manualSetup } from 'ember-data-factory-guy';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('correspondence', 'Integration | Component | Correspondence Details', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
  },
});

test('shows the history if there are activities', function(assert) {
  let paper = make('paper');
  let correspondence = make('correspondence', 'externalCorrespondence', {
    activities: [
      { key: 'correspondence.created', full_name: 'Jim', created_at: '1989-8-19' }
    ],
    paper: paper
  });
  const can = FakeCanService.create().allowPermission('manage_workflow', paper);
  this.register('service:can', can.asService());

  this.set('correspondence', correspondence);
  this.render(hbs`{{correspondence-details message=correspondence}}`);
  assert.textPresent('.history-heading', 'History');
  assert.textPresent('.history-entry', 'Added by Jim');
});
