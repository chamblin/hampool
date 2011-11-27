class QuestionPoolReader
  def initialize(fp=nil)
    @fp = fp
    @current_section = nil
    @current_question = nil
  end
  
  def data
    @data ||= @fp.read
  end
  
  def next_question
    chop_to_next_question!
    if end_of_question_offset
      result = (data && data[Range.new(0, end_of_question_offset)])
      chop_to_end_of_question!
    else
      result = nil
    end
    return (result && HamQuestion.parse_question(result))
  end
  
  def questions
    if @questions.nil?
      r = []
      while q = next_question
        r << q
      end
      @questions = r
    end
    @questions
  end
  
  def questions_as_hash
    if @questions_as_hash.nil?
      h = {}
      questions.each do |question|
        h[question.id] = question
      end
      @questions_as_hash = h
    end
    return @questions_as_hash
  end
  
  private
    def next_question_begins_offset
      data =~ /^T\d+[A-Z]\d+ \([A-D]\)/ 
    end
    
    def end_of_question_offset
      data =~ /^~~\s+$/
    end
    
    def chop_to_next_question!
      if next_question_begins_offset
        @data = data[Range.new(next_question_begins_offset, -1)]
      else
        @data = nil
      end
    end
    
    def chop_to_end_of_question!
      if end_of_question_offset
        @data = data[Range.new(end_of_question_offset, -1)]
      else
        @data = nil
      end
    end
end

class HamQuestionPool
  def initialize(reader=nil)
    @reader = reader
  end
  
  def test_questions(question_ids)
    question_ids.collect{|id| @reader.questions_as_hash[id]}
  end
end

class HamQuestion
  attr_reader :id, :question, :answers, :correct_answer
  def initialize(id, question=nil, answers=[], correct_answer=nil)
    @id = id
    @question = question
    @answers = answers
    @correct_answer = correct_answer
  end
  
  def self.parse_question(question)
    lines = question.split("\n")
    id = lines[0].split(" ")[0]
    correct_answer = lines[0].scan(/\(([A-D])\)/)[0][0] rescue nil
    question = lines[1]
    answers = lines[2..-2]
    self.new(id, question, answers, correct_answer)
  end
end