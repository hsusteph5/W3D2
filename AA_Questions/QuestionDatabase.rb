require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_name(fname, lname)
    user_array = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless user_array.length > 0
    
    User.new(user_array.first) # play is stored in an array!
  end

  def self.find_by_id(id)
    user_array = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless user_array.length > 0
    
    User.new(user_array.first) # play is stored in an array!
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
  
  # Question.find_by_author_id(id)
  def authored_questions
    arr_questions = Question.find_by_author(@id) #[questions]
  end
  
  def authored_replies
    arr_replies = Reply.find_by_user_id(@id)
  end
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end
end

class Question
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_author(author_id)
    question_array = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    return nil unless question_array.length > 0

    question_array.map! {|hash| Question.new(hash) }  # play is stored in an array!
  end
  
  def self.find_by_id(id)
    question_array = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil unless question_array.length > 0

    question_array.map! {|hash| Question.new(hash) }  # play is stored in an array!
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
  
  def author
    User.find_by_id(@author_id)
  end
  
  def replies
    Reply.find_by_question_id(@id)
  end
  
  def followers
    QuestionFollow.followers_for_question_id(@id)
  end
end

class Reply
  attr_accessor :body, :user_id, :question_id, :parent_id
  
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end
  
  def self.find_by_user_id(user_id)
    replies_array = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless replies_array.length > 0

    replies_array.map! {|hash| Reply.new(hash) } 
  end
  
  def self.find_by_question_id(question_id)
    replies_array = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless replies_array.length > 0

    replies_array.map! {|hash| Reply.new(hash) } 
  end
  
  def self.find_by_own_id(id)
    replies_array = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil unless replies_array.length > 0
  
     Reply.new(replies_array.first)
  end
  
  def self.find_by_children_id(parent_id)
    replies_array = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    return nil unless replies_array.length > 0
  
     replies_array.map! {|hash| Reply.new(hash) } 
  end
  
  def initialize(options)
    @id = options['id']
    @body = options['body']
    @user_id = options['user_id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
  end
  
  def author
    User.find_by_id(@user_id)
  end
  
  def question
    Question.find_by_id(@question_id)
  end
  
  def parent_reply
    Reply.find_by_own_id(@parent_id)
  end 
  
  def child_reply
    Reply.find_by_children_id(@id)
  end 
  
end



class QuestionFollow
  attr_accessor :user_id, :question_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    follow_arr = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        user_id
      FROM
        question_follows
      WHERE
        question_id = ?
    SQL
    return nil unless follow_arr.length > 0
    
    follow_arr.map do |hash|
      User.find_by_id(hash['user_id'])
    end
  end
  
  def self.followed_questions_for_user_id(user_id)
    follow_arr = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        question_id
      FROM
        question_follows
      WHERE
        user_id = ?
    SQL
    return nil unless follow_arr.length > 0
    
    follow_arr.map do |hash|
      Question.find_by_id(hash['question_id'])
    end
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
  
end