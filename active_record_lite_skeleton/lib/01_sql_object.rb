require 'byebug'
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
  end

  def self.finalize!
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
  end



  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    sql_statement = <<-SQL
    SELECT
      #{self.new.class.to_s.downcase}s.*
    FROM
      #{self.new.class.to_s.downcase}s
    SQL
    parse_all DBConnection.execute(sql_statement)

  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    sql_statement = <<-SQL
    SELECT
      #{self.new.class.to_s.downcase}s.*
    FROM
    #{self.new.class.to_s.downcase}s
    WHERE
    #{self.new.class.to_s.downcase}s.id = ?
    SQL
    parse_all(DBConnection.execute(sql_statement, id)).first
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
    self.class.columns.map {|col| self.send(col) }
  end

  def insert
    cols = self.class.columns.dup
    cols.delete(:id)
    col_names = cols.join(',')
    question_marks = (['?'] * (attribute_values.size - 1)).join(',')
    # byebug
    sql_statement = <<-SQL
    INSERT INTO
      #{self.class.to_s.downcase}s (#{col_names})
    VALUES
      (#{question_marks})
    SQL
    DBConnection.execute(sql_statement, *attribute_values[1..-1])
    self.id = DBConnection.last_insert_row_id
  end

  def update
    cols = self.class.columns.dup
    cols.delete(:id)
    col_names = cols.map {|col| "#{col} = ?"}.join(',')
    
    sql_statement = <<-SQL
    UPDATE
    #{self.class.to_s.downcase}s
    SET
    #{col_names}
    WHERE
      ?
    SQL

    DBConnection.execute(sql_statement, *attribute_values[1..-1], attribute_values[0])

  end

  def save
    # ...
  end
end
