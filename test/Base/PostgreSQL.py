#!/usr/bin/env python2

"""
Class for accessing Postgres databases and be able to run queries against it, retrieving results
and/or performing modifications.

Psycopg2 can be installed via the following command:

  sudo pip install psycopg2

"""

__author__ = 'jgray@plos.org'

import psycopg2
from Resources import psql_hname, psql_port, psql_uname, psql_pw, psql_db

class PgSQL(object):

  def _getConnection(self):
    cnxstring = 'host=' + str(psql_hname) + ' ' + 'port=' + str(psql_port) + ' ' + 'user=' + str(psql_uname) + ' ' \
                + 'password=' + str(psql_pw) + ' ' + 'dbname=' + str(psql_db)
    conn = psycopg2.connect(cnxstring)
    return conn

  def query(self, query, queryArgsTuple=None):
    conn = self._getConnection()

    with conn.cursor() as cursor:
      cursor.execute(query, queryArgsTuple)
      results = cursor.fetchall()
      cursor.close()
    conn.close()
    return results

  def modify(self, query, queryArgsTuple=None):
    conn = self._getConnection()
    with conn.cursor() as cursor:
      cursor.execute(query, queryArgsTuple)
      conn.commit()
      cursor.close()
    conn.close()
