class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name: , breed: , id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
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
        if self.id
            self.update
        else 
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = Dog.last_id
        end 
        self
    end
    
    def self.last_id
        id = <<-SQL
            SELECT id
            FROM dogs
            ORDER BY id DESC
            LIMIT 1
            SQL
        DB[:conn].execute(id)[0][0]
    end 

    def self.create(name:, breed:) 
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end
    
    def self.new_from_db(row)
        dog = Dog.new(name: row[1], breed: row[2], id: row[0])
        dog
    end 

    def self.find_by_id(x)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id
        IS ?;
        SQL
        dog = DB[:conn].execute(sql,x)[0]
        new_from_db(dog)
    end 

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        AND breed = ?
        LIMIT 1;
        SQL
        dog = DB[:conn].execute(sql,name,breed)
        if !dog.empty?
            dog_id = dog.flatten[0]
            dog = Dog.new(name: name, breed: breed, id: dog_id)
        else
            dog = Dog.create(name: name, breed: breed)
        end 
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name
        IS ?
        LIMIT 1;
        SQL
        dog = DB[:conn].execute(sql, name).flatten
        Dog.new(name: dog[1], breed: dog[2], id: dog[0])
    end 

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id
        IS ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end 