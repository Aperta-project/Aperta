`import DS from 'ember-data'`

a = DS.attr

AdminJournal = DS.Model.extend

  manuscriptManagerTemplates: DS.hasMany('manuscriptManagerTemplate')
  roles: DS.hasMany('role')
  journalTaskTypes: DS.hasMany('journalTaskType')

  logoUrl: a('string')
  name: a('string')
  paperTypes: a()
  epubCoverUrl: a('string')
  epubCoverFileName: a('string')
  epubCss: a('string')
  pdfCss: a('string')
  manuscriptCss: a('string')
  description: a('string')
  paperCount: a('number')
  createdAt: a('date')
  doiJournalPrefix: a('string')
  doiPublisherPrefix: a('string')
  lastDoiIssued: a('number')
  doi: a()

`export default AdminJournal`
