a = DS.attr
ETahi.Dashboard = DS.Model.extend
  submissions: DS.hasMany('litePaper')
  user: DS.belongsTo('user')
