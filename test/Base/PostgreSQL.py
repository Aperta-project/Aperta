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

  @staticmethod
  def _get_connection():
    cnxstring = 'host=' + str(psql_hname) + ' ' + 'port=' + str(psql_port) + ' ' + 'user=' + str(psql_uname) + ' ' \
                + 'password=' + str(psql_pw) + ' ' + 'dbname=' + str(psql_db)
    conn = psycopg2.connect(cnxstring)
    return conn

  def query(self, query, query_args_tuple=None):
    conn = self._get_connection()

    with conn.cursor() as cursor:
      cursor.execute(query, query_args_tuple)
      results = cursor.fetchall()
      cursor.close()
    conn.close()
    return results

  def modify(self, query, query_args_tuple=None):
    conn = self._get_connection()
    with conn.cursor() as cursor:
      cursor.execute(query, query_args_tuple)
      conn.commit()
      cursor.close()
    conn.close()