require 'hampool'

questions = HamQuestionPool.new(QuestionPoolReader.new(File.open("Technician Class Question Pool.txt"))).test_questions(ARGV).compact
correct = 0
missed = []
questions.shuffle.each do |question|
  puts "%s - %s" % [question.id, question.question]
  puts question.answers.join("\n")
  print ">"

  answer = STDIN.gets.strip.upcase
  if answer == question.correct_answer
    correct += 1
    puts "CORRECT"
  else
    missed << question
    puts "INCORRECT"
  end
  puts
end
puts
puts
puts "Your total score was %s/%s, for an average score of %s%%." % [correct, questions.length, correct.to_f/questions.length * 100]
if not missed.empty?
  puts "You missed these questions\n-----------------"
  puts missed.collect{|q| q.id}.join("\n")
end