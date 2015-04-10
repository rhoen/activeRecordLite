require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject


  def self.columns
    columns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}

    SQL
    .first.map(&:to_sym)

    columns.each do |col|
      #setter
      define_method(col) do
        # iv = self.instance_variable_get("@#{col.to_s}".to_sym)
        attributes[col]
      end
      #getter
      define_method("#{col}=") do |val|
        attributes[col] = val
        # self.instance_variable_set("@#{col.to_s}", val)
      end
    end

    columns
  end

  def self.finalize!
  end



  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    params.each do |key, value|
      unless self.class.columns.include?(key.to_sym)
        raise "unknown attribute '#{key}'"
      else
        self.send("#{key.to_sym}=", value)
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
