import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('admin-page/workflow-thumbnail',
  'Integration | Component | admin page | workflow thumbnail', {
    integration: true
  }
);

const workflow = {
  paperType: 'Research',
  updatedAt: '2017-02-07T13:54:58.028Z',
  activePaperCount: 1
};


test('it shows the paper type', function(assert) {
  this.set('workflow', workflow);
  this.render(hbs`{{admin-page/workflow-thumbnail workflow=workflow}}`);

  assert.textPresent('.admin-workflow-thumbnail-name', 'Research');
});


test('it shows when the workflow was last updated', function(assert) {
  this.set('workflow', workflow);
  this.render(hbs`{{admin-page/workflow-thumbnail workflow=workflow}}`);

  assert.textPresent('.admin-workflow-thumbnail-updated', 'Feb 7, 2017');
});


test('it shows the number of active manuscripts', function(assert) {
  this.set('workflow', workflow);
  this.render(hbs`{{admin-page/workflow-thumbnail workflow=workflow}}`);

  assert.textPresent(
    '.admin-workflow-thumbnail-active-manuscripts',
    '1 Active Manuscript'
  );
});
