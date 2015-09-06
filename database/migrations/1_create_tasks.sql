CREATE TABLE tasks (id INTEGER NOT NULL PRIMARY KEY,
                    description VARCHAR NOT NULL,
                    time_cost INTEGER,
                    completed BOOLEAN NOT NULL DEFAULT 0 CHECK (completed IN (0,1)),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);
