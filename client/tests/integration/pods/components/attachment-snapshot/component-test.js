/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import {moduleForComponent, moduleFor, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import SnapshotAttachment from 'tahi/pods/snapshot/attachment/model';

moduleForComponent('attachment-snapshot',
                   'Integration | Component | attachment-snapshot',
                   {integration: true,
                    beforeEach: function() {
                      registerDiffAssertions();
                      initTruthHelpers();
                    }});

var snapshot = function(attrs){
  let properties = _.extend({
    id: 32,
    caption: 'my caption oh caption',
    category: 'category one fever',
    file: 'theFile.jpg',
    file_hash: 'a9876a98c987b96h',
    label: 'jars, not people',
    publishable: true,
    status: 'processing',
    title: 'squid',
    url: '/path/to/theFile.jpg'
  }, attrs);
  return SnapshotAttachment.create({
    attachment: {
      name: 'attachment',
      children: [
        { name: 'id', type: 'integer', value: properties.id },
        { name: 'caption', type: 'text', value: properties.caption },
        { name: 'category', type: 'text', value: properties.category },
        { name: 'file', type: 'text', value: properties.file },
        { name: 'file_hash', type: 'text', value: properties.file_hash },
        { name: 'label', type: 'text', value: properties.label },
        { name: 'publishable', type: 'boolean', value: properties.publishable },
        { name: 'status', type: 'text', value: properties.status },
        { name: 'title', type: 'text', value: properties.title },
        { name: 'url', type: 'url', value: properties.url }
      ]
    }
  });
};

var template = hbs`{{attachment-snapshot
                     attachment1=newSnapshot
                     attachment2=oldSnapshot}}`;

test('no diff, no added or removed', function(assert){
  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', snapshot());

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

//
// Simple properties that all follow the same display conventions:
//

testProperty('caption');
testProperty('category');
testProperty('label');
testProperty('publishable', { diffType: 'boolean' });
testProperty('title');


//
// File/fileHash/url is a little more complex than simple properties
// so they are tested separtely
//

test('when file is present and unchanged, it is displayed', function(assert){
  this.set('oldSnapshot', snapshot({file: 'picture.jpg', url: 'carebears.jpg'}));
  this.set('newSnapshot', snapshot({file: 'picture.jpg', url: 'carebears.jpg'}));

  this.render(template);

  assert.elementFound(`.attachment-snapshot-file a[href="carebears.jpg"]:contains(picture.jpg)`);
});

test('when file is present and its fileHash has changed, it is diffed', function(assert){
  this.set('oldSnapshot', snapshot({
    file: 'removedFile.jpg',
    file_hash: 'abc123',
    url: '/path/to/removedFile.jpg'
  }));
  this.set('newSnapshot', snapshot({
    file: 'addedFile.jpg',
    filehash: 'xyz789',
    url: '/path/to/addedFile.jpg'
  }));

  this.render(template);

  assert.linkDiffPresent({
    removed: { text: 'removedFile.jpg', url: '/path/to/removedFile.jpg' },
    added: { text: 'addedFile.jpg', url: '/path/to/addedFile.jpg' }
  });
});

function testProperty(property, options = {}){
  let cssClass = options.cssClass || property;
  let diffType = options.diffType;

  testBlankPropertyIsNotDisplayed(property, { cssClass: cssClass });

  if(diffType === 'boolean'){
    testBooleanPropertyWithoutDiff(property, { cssClass: cssClass });
    testBooleanPropertyWithDiff(property);
  } else {
    testTextPropertyWithoutDiff(property, { cssClass: cssClass });
    testTextPropertyWithDiff(property);
  }
}

function testBlankPropertyIsNotDisplayed(property, options){
  let cssClass = options.cssClass || property;

  test(`when ${property} is not present, it is not displayed`, function(assert){
    let oldProperties = {}, newProperties = {};

    oldProperties[property] = null;
    newProperties[property] = null;

    this.set('oldSnapshot', snapshot(oldProperties));
    this.set('newSnapshot', snapshot(newProperties));

    this.render(template);

    assert.elementNotFound(`.attachment-snapshot-${cssClass}`);
  });
}

function testBooleanPropertyWithDiff(property){
  test(`when ${property} is different (boolean), it is displayed as a diff`, function(assert){
    let oldProperties = {}, newProperties = {};

    oldProperties[property] = false;
    newProperties[property] = true;

    this.set('oldSnapshot', snapshot(oldProperties));
    this.set('newSnapshot', snapshot(newProperties));

    this.render(template);

    assert.diffPresent('No', 'Yes');
  });
}

function testBooleanPropertyWithoutDiff(property, options){
  let cssClass = options.cssClass || property;

  test(`when ${property} (boolean) is present and unchanged , it is displayed, not diffed`, function(assert){
    let oldProperties = {}, newProperties = {};
    let value = 'Yes';

    oldProperties[property] = true;
    newProperties[property] = true;

    this.set('oldSnapshot', snapshot(oldProperties));
    this.set('newSnapshot', snapshot(newProperties));

    this.render(template);

    assert.elementFound(`.attachment-snapshot-${cssClass}:contains(${value})`);
    assert.notDiffed(value, value);
  });
}

function testTextPropertyWithDiff(property){
  test('when ${property} is different (text), it is displayed as a diff', function(assert){
    let oldProperties = {}, newProperties = {};

    oldProperties[property] = `my old ${property} value`;
    newProperties[property] = `my new ${property} value`;

    this.set('oldSnapshot', snapshot(oldProperties));
    this.set('newSnapshot', snapshot(newProperties));

    this.render(template);

    assert.diffPresent(oldProperties[property], newProperties[property]);
  });
}

function testTextPropertyWithoutDiff(property, options){
  let cssClass = options.cssClass || property;

  test(`when ${property} (text) is present and unchanged, it is displayed, not diffed`, function(assert){
    let oldProperties = {}, newProperties = {};
    let value = `a ${property} value`;

    oldProperties[property] = value;
    newProperties[property] = value;

    this.set('oldSnapshot', snapshot(oldProperties));
    this.set('newSnapshot', snapshot(newProperties));

    this.render(template);

    assert.elementFound(`.attachment-snapshot-${cssClass}:contains(${value})`);
    assert.notDiffed(oldProperties[property], newProperties[property]);
  });
}
