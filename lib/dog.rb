require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    def initialize(attributes)

        attributes.each {|key, value| self.send("#{key}=",value)}

    end

    def self.create_table

        sql = <<~SQL

            CREATE TABLE IF NOT EXISTS dogs (

                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT

            );
        
        SQL

        DB[:conn].execute(sql)
        
    end

    def self.drop_table

        sql = "DROP TABLE IF EXISTS dogs;"

        DB[:conn].execute(sql)
        
    end
    
    def save

        if @id

            self.update

        else

            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, @name, @breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;").flatten.first
            return self
        end
        
    end

    def self.create(attributes)

        doggo = Dog.new(attributes)
        doggo.save
        doggo
        
    end

    def self.new_from_db(row)
        
        hash = {name: row[1], breed: row[2], id: row[0]}
        Dog.new(hash)
        
    end

    def self.find_by_id(id)

        sql = "SELECT * FROM dogs WHERE id = ?"
        results = DB[:conn].execute(sql, id).flatten
        self.new_from_db(results)
        
    end

    def self.find_or_create_by(hash)

        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"

        name = hash[:name]
        breed = hash[:breed]
        result = DB[:conn].execute(sql, name, breed).flatten

        if result.empty?

            self.create(hash)
            
        else
            
            self.new_from_db(result)
            
        end


    end

    def self.find_by_name(name)

        sql = "SELECT * FROM dogs WHERE name = ?"

        result = DB[:conn].execute(sql, name).first

        self.new_from_db(result)
        
    end

    def update

        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
        DB[:conn].execute(sql, @name, @breed, @id)

    end

end