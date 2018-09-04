DROP TABLE IF EXISTS question_tags;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS users;
-- users have to be last 

PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  -- likes INTEGER,
  -- 
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);


INSERT INTO 
  users (fname, lname)
VALUES 
  ('Derek', 'Choe'),
  ('Stephanie', 'Hsu');
  
INSERT INTO 
  questions (title, body, author_id)
VALUES
  ('Assessment question', 'Will we have a test generator for the next assessment?', (SELECT id FROM users WHERE fname = 'Derek')),
  ('Inqueries about lunch', 'When is lunch?', (SELECT id FROM users WHERE fname = 'Stephanie')),
  ('Fire Alarm concerns', 'What was on fire?', (SELECT id FROM users WHERE fname = 'Stephanie'));
  
INSERT INTO
  question_follows (question_id, user_id)
VALUES 
  ((SELECT id FROM questions WHERE title = 'Assessment question'), (SELECT id FROM users WHERE fname = 'Stephanie')),
  ((SELECT id FROM questions WHERE title = 'Assessment question'), (SELECT id FROM users WHERE fname = 'Derek')),
  ((SELECT id FROM questions WHERE title = 'Inqueries about lunch'), (SELECT id FROM users WHERE fname = 'Derek')),
  ((SELECT id FROM questions WHERE title = 'Fire Alarm concerns'), (SELECT id FROM users WHERE fname = 'Derek'));

INSERT INTO 
  replies (body, user_id, question_id, parent_id)
VALUES 
-- the parent for Assessment question
  ('To be determined', 
    (SELECT id FROM users WHERE fname = 'Stephanie'),
    (SELECT id FROM questions WHERE title = 'Assessment question'),
    NULL
  ),
  ('Wth?!', 
    (SELECT id FROM users WHERE fname = 'Derek'),
    (SELECT id FROM questions WHERE title = 'Assessment question'),
    1
    -- (SELECT id FROM replies WHERE body = 'To be determined')
  ),
-- the parent for fire question
  ('Someone''s cat!', 
    (SELECT id FROM users WHERE fname = 'Derek'),
    (SELECT id FROM questions WHERE title = 'Fire Alarm concerns'),
    NULL
  );
  
  
  INSERT INTO
    question_likes(question_id, user_id)
  VALUES 
    ((SELECT id FROM questions WHERE title = 'Assessment question'), (SELECT id FROM users WHERE fname = 'Stephanie')),
    ((SELECT id FROM questions WHERE title = 'Assessment question'), (SELECT id FROM users WHERE fname = 'Derek'));
    
  