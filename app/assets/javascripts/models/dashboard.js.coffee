a = DS.attr
ETahi.Dashboard = DS.Model.extend
  totalPaperCount: a('number')
  papers: DS.hasMany('litePaper')
  user: DS.belongsTo('user')
  totalPageCount: a('number')
