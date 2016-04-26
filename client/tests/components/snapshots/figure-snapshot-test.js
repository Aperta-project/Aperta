import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';

moduleForComponent('figure-snapshot',
                   'Integration: figure-snapshot-component',
                   {integration: true,
                    beforeEach: function() {
                      registerDiffAssertions();
                    }});

var snapshot = function (){
  return {
    name: 'figure',
    children: [
      {name: 'id', value: 'foo'},
      {name: 'title', value: 'squid'},
      {name: 'file', value: 'theFile.jpg'},
      {name: 'striking_image', value: true},
      {name: 'file_hash', value: 'a9876a98c987b96h'}
    ]
  }
};

var template = hbs`{{figure-snapshot
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

test('Diffs the striking image bool', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[3].value = false;

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent("Yes", "No");
});

test('Diffs the filename when the file has changed', function(assert) {
  let secondSnaps = snapshot();
  secondSnaps.children[4].value = 'anewhashverydifferentmuchchange';

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent('theFile.jpg', 'theFile.jpg');
});
