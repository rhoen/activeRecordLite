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
        #{self.class.to_s.downcase}
      WHERE
        #{where_line}
    SQL

    DBConnection.execute(sql_statement, params.values)
  end
end

class SQLObject
  extend Searchable
end
