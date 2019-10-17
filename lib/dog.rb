class Dog

    attr_accessor :name, :breed
    attr_reader :id
    
    def initialize(args)
        @id = args[:id]
        @name = args[:name]
        @breed = args[:breed]
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
          sql = <<-SQL
          INSERT INTO dogs (name, breed) 
            VALUES(?,?)
          SQL
            #you wrote DB[:comm] instead of DB[:conn]
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
       sql = "UPDATE dogs SET name = ?, breed = ?"
       
       DB[:conn].execute(sql, self.name, self.breed)
    end

    def self.create(args)
        dog = Dog.new(args)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL

       new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs 
        WHERE name = ? 
        AND breed = ? 
        LIMIT 1
        SQL

        dogs = DB[:conn].execute(sql, name, breed)

        if !dogs.empty?
            dogs_data = dogs[0]
            dog = Dog.new(id: dogs_data[0],name: dogs_data[1],breed: dogs_data[2])
        else
            dog = create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL

        new_from_db(DB[:conn].execute(sql,name)[0])
    end

end

