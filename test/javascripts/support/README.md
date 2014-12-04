**Purpose:** Document the state of the QUnit test helpers on the Tahi Ember app

## What's wrong with hand-crafted JSON?
It's beautiful, there's no doubt. It's also hard to maintain, because:
 1. The API may change, but hunting through the JSON to update it is painful
 1. The entire payload may not be relevant to what's being tested
 1. It's easier to copy and paste the payload than re-write it specifically for
 each test (thus propagating issue 2)
 1. It's harder to figure out which parts of the payload are actually being
    tested

## Ok, what's the alternative?
In the `test/javascripts/support/` directory, there is a `factories` file and a
`setups` directory. Both contain helper methods that can create JSON payloads
for you. The idea is to assemble a JSON payload by creating and adding
individual records to it. This payload would then be used as a mock server
response to a request.

Let's look at `factories` first.

### `factories.js.coffee`
This is a big file, and can be overwhelming to look through. The bottom 200 or
so lines are all factory attributes for the different models we have in the
app, so they can be disregarded for now.  The top-level namespace is
ETahi.Factory, so you'll see this a lot in the updated integration tests:

```coffee
ef = ETahi.Factory
```
The important methods in this namespace are:

##### `createPayload` and `toJSON`
`createPayload` takes a underscored type key, and creates an empty payload
object. Calling `toJSON()` on this payload object returns a JSON object that
can be used as the server response for that type. For example:

```coffee
adminJournalPayload = ef.createPayload('admin_journal')
# => Object
{manifest: Object, createRecord: function, addRecords: function, addRecord: function, toJSON: function}
adminJournalPayload.toJSON()
# => Object {}
```
The payload is currently empty because we haven't added any records to it. The
payload object has `addRecords` and `addRecord` methods on it, which allow you
to populate the payload. We'll get to those in a second.

##### `createRecord`
Takes a type (e.g. 'Journal'), and attributes, and creates an object that can
be added to a payload:

```coffee
adminJournal = ef.createRecord('AdminJournal')
# => Object {id: 1, _rootKey: "journal", name: "Fake Journal", logo_url: "/images/no-journal-image.gif"…}
```
The defaults for the record are the `FactoryAttributes` for that type, and can
be overridden by the attributes passed in to `createRecord`.

##### `addRecord` and `addRecords`
Now that you have a record, you can add it to a newly-created payload object.
Putting it all together:

```coffee
adminJournalPayload = ef.createPayload('admin_journal')
adminJournal = ef.createRecord('AdminJournal')

adminJournalPayload.addRecord(adminJournal)

adminJournalPayload.toJSON()
# => Object {admin_journal: Object}
```
The `addRecord` method is smart enough to match the record type with the type
of the payload, and adds non-matching records as sideloaded JSON with a
pluralized key. `addRecords` takes a collection and adds them all to the
payload.

##### `addHasMany`
Takes a primary record and a list of records that need to be associated to the
primary record, and creates the associations based on the passed in options
(`embed`, `merge` or `inverse`).

This method may be used, for example, to add many phases to a paper:

```coffee
paper = ef.createRecord('Paper')
newPhase = ef.createRecord('Phase')
ef.addHasMany(paper, [newPhase], {inverse: 'paper'})
```

Then, when you add the paper and phases to the payload, the paper will have the
correct phase\_ids and the phases will have the correct paper\_id set. There
are several helpers that create specific kinds of records with associations,
e.g. `createTask`, `createMMT`, `createJournalTaskType` and so on. Feel free to
add your own.

### `setups/`
This directory currently only has one file, `paper_setups`. Other setups may be
added as needed, such as `journal_setups`. The methods in the file lack
consistency, but their purpose is to do a bunch of steps that would allow you
to create a specific kind of paper payload. You can mock a server response to
`/papers/:id` with the result of calling `toJSON` on this object. We'll look at
a couple:

* `paperWithParticipant`: Returns a payload object with a paper, task and a
  participation for a user (among other things). 
* `paperWithTask`: Returns paper, task and associated records that can be added
  to a payload object. This is a more flexible approach, since it allows the
  test to access the records before adding them to a payload. The downside is
  that the test needs to do the `createPayload` and `addRecords` step.

### Other things to remember
* There is a `getNewId` method which is responsible for generating new ids for
  a type of model. So instead of coming up with random numbers in a test to
  verify them later, you should use `createRecord`, and cache the id from there
  to use for stubbing or verifying.
* `createList` will create multiple default records of a type
* If there's a record you want that isn't currently supported, just add a
  `ETahi.FactoryAttributes` entry for it, and `createRecord` will *just work*.
* The `ETahi.Factory` and `ETahi.Setups` are available on the `/qunit` screen,
  so feel free to play around in the console to see how the helpers work. As
  always, `debugger` is your friend.
