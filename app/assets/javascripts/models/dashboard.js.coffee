a = DS.attr
ETahi.Dashboard = DS.Model.extend
  paginate: a('boolean')
  totalPaperCount: a('number')
  papers: DS.hasMany('litePaper')
  user: DS.belongsTo('user')
