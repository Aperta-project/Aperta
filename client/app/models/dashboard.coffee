`import DS from 'ember-data'`

a = DS.attr

Dashboard = DS.Model.extend

  papers: DS.hasMany('litePaper')
  user: DS.belongsTo('user')

  totalPaperCount: a('number')
  totalPageCount: a('number')

`export default Dashboard`
