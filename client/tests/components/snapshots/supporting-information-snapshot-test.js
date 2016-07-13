import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';

moduleForComponent('supporting-information-snapshot',
                   'Integration | Component | supporting information snapshot',
                   {integration: true,
                    beforeEach: function() {
                      registerDiffAssertions();
                    }});

var snapshot = function (attrs){
  let properties = _.extend({
    id: 'foo',
    title: 'squid',
    file: 'theFile.jpg',
    caption: 'I\'m the caption now',
    publishable: true,
    striking_image: true,
    file_hash: 'a9876a98c987b96h',
    url: '/path/to/theFile.jpg'
  }, attrs);
  return {
    name: 'supporting-information-file',
    children: [
      {name: 'id', value: properties.id},
      {name: 'title', value: properties.title},
      {name: 'file', value: properties.file},
      {name: 'caption', value: properties.caption},
      {name: 'publishable', value: properties.publishable},
      {name: 'striking_image', value: properties.striking_image},
      {name: 'file_hash', value: properties.file_hash},
      {name: 'url', value: properties.url}
    ]
  };
};

var template = hbs`{{supporting-information-snapshot
                     snapshot1=newSnapshot
                     snapshot2=oldSnapshot}}`;

test('no diff, no added or removed', function(assert){
  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', snapshot());

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test('Diffs the title', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[1].value = 'Title here';

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent('squid', 'Title here');
});

test('Diffs the filename', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[2].value = 'newFile.jpg';

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent('theFile.jpg', 'newFile.jpg');
});

test('Diffs the caption', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[3].value = 'look at me';

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent('I\'m the caption now', 'look at me');
});

test('Diffs the publishable', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[4].value = false;

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent('Yes', 'No');
});

test('Diffs the striking image bool', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[5].value = false;

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent('Yes', 'No');
});

test('Diffs the filename when the file has changed', function(assert) {
  let firstSnaps = snapshot({
    file: 'removedFile.jpg',
    file_hash: 'theoriginalfilehash',
    url: '/path/to/removedFile.jpg'
  });
  let secondSnaps = snapshot({
    file: 'addedFile.jpg',
    file_hash: 'anewhashverydifferentmuchchange',
    url: '/path/to/addedFile.jpg'
  });

  this.set('oldSnapshot', firstSnaps);
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.linkDiffPresent({
    removed: { text: 'removedFile.jpg', url: '/path/to/removedFile.jpg' },
    added: { text: 'addedFile.jpg', url: '/path/to/addedFile.jpg' }
  });
});

test('Shows the filename added when null in comparing snapshot', function(assert) {
  let secondSnaps = snapshot();
  secondSnaps.children[2].value = null;
  secondSnaps.children[6].value = null;

  this.set('oldSnapshot', secondSnaps);
  this.set('newSnapshot', snapshot());

  this.render(template);

  assert.equal(this.$('.added').length, 1, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test('Shows the filename removed when null in viewing snapshot', function(assert) {
  let secondSnaps = snapshot();
  secondSnaps.children[2].value = null;
  secondSnaps.children[6].value = null;

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 1, 'Has removed diff spans');
});
