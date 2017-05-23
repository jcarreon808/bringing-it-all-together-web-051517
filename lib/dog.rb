require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed INTEGER
      );
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
      SQL

      DB[:conn].execute(sql)
  end

  def save
  # if self.id
  #   self.update
  # else
  sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?);
    SQL
    DB[:conn].execute(sql,[self.name,self.breed])
    @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
    self
  # end
  end

  def self.create(hash)
      new_dog= Dog.new(hash)
      new_dog.save
      new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id =?;
      SQL
      row = DB[:conn].execute(sql,[id]).flatten
      Dog.new({id:row[0],name:row[1],breed:row[2]})
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed= ?", name, breed)
    if !dog.empty?
      dogs_data = dog[0]
      dog = Dog.new(id:dogs_data[0], name:dogs_data[1], breed:dogs_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new({id:row[0],name:row[1],breed:row[2]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * from dogs WHERE name =?;
      SQL
      row = DB[:conn].execute(sql,name).flatten
      self.new_from_db(row)
  end

  def update
  sql = <<-SQL
    UPDATE dogs SET name=? , breed=? WHERE id=?;
    SQL
    DB[:conn].execute(sql,[name,breed,id])
  end
end
