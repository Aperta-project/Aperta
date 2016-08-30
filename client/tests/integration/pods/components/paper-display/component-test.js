import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('paper-display', 'Integration | Component | paper display', {
  integration: true
});

const fakeJournal = {
  then(callback) {
    callback({ get(){ return 'color: red;'; } });
  },
};

test('it displays a spinner when the paper is processing', function(assert) {
  assert.expect(2);

  this.paper = {
    processing: true,
    body: '<p>science!</p>',
    journal: fakeJournal,
  };

  this.render(hbs`{{paper-display paper=paper}}`);

  const spinner = this.$('.progress-spinner');
  assert.equal(spinner.length, 1, 'there should be a spinner');
  const paperBody = this.$('#paper-body');
  assert.equal(paperBody.length, 0, 'there should be no paper-body');
});

test('it doesnt display a spinner when not processing', function(assert) {
  assert.expect(2);

  this.paper = {
    processing: false,
    body: '<p>science!</p>',
    journal: fakeJournal
  };

  this.render(hbs`{{paper-display paper=paper}}`);

  const spinner = this.$('.progress-spinner');
  assert.equal(spinner.length, 0, 'there should not be a spinner');
  const paperBody = this.$('#paper-body');
  assert.equal(paperBody.length, 1, 'there should be a paper-body');
});
