`import ApplicationSerializer from 'tahi/serializers/application'`

PaperSerializer = ApplicationSerializer.extend

  attrs:
    authors:
      serialize: false
    collaborations:
      serialize: false
    editors:
      serialize: false
    figures:
      serialize: false
    phases:
      serialize: false
    reviewers:
      serialize: false
    supportingInformationFiles:
      serialize: false
    tasks:
      serialize: false

`export default PaperSerializer`
