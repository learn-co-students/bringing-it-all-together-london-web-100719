class Dog

    attr_accessor :id, :name, :breed

    def initialize(attributes)
        attributes.each do |key, value|
            self.send(("#{key}="), value)
        end
    end

    def self.create_table 
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def self.new_from_db(row)
        attributes = {
            id: row[0],
            name: row[1],
            breed: row[2]
        }
        Dog.new(attributes)
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def save 
        if self.id
            self.update
        else 
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (? , ?)
            SQL

            # require 'pry'
            # binding.pry

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self

        end
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(attributes)
        new_dog = Dog.new(attributes)
        new_dog.save
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL

        dog_row = DB[:conn].execute(sql, id)[0]
        new_from_db(dog_row)        
    end

    def self.find_or_create_by(attributes)
        require 'pry'

        sql = <<-SQL
            SELECT * FROM dogs 
            WHERE name = ? AND breed = ?
        SQL

        dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed]).flatten

        if dog.empty?
            dog = self.create(attributes)        
        else
            self.new_from_db(dog)
        end
    end
end