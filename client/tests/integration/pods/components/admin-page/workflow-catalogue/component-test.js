import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('admin-page/workflow-catalogue',
  'Integration | Component | Admin Page | Workflow Catalogue', {
    integration: true
  }
);

const workflow = {
  paperType: 'Research',
  updatedAt: '2017-02-07T13:54:58.028Z',
  activePaperCount: 1
};

test('it renders a catalogue item for each workflow', function(assert) {
  const workflows = [workflow, workflow, workflow];
  this.set('workflows', workflows);

  this.render(hbs`
    {{admin-page/workflow-catalogue workflows=workflows}}
  `);

  assert.nElementsFound('.admin-workflow-thumbnail', workflows.length);
});
