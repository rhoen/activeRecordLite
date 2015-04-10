require 'byebug'
require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.map do |key, value|
      "#{key} = ?"
    end.join(' AND ')

    sql_statement = <<-SQL
      SELECT
        *
      FROM
        #{self.to_s.downcase}s
      WHERE
        #{where_line}
    SQL

    parse_all DBConnection.execute(sql_statement, params.values)
  end
end

class SQLObject
  extend Searchable
end
