require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...
  end
end

class SQLObject
  include Searcheable
end
