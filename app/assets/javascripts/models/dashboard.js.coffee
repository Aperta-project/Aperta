a = DS.attr
ETahi.Dashboard = DS.Model.extend
  papers: DS.hasMany('litePaper')
  user: DS.belongsTo('user')
