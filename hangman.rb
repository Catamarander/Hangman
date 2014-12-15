class Hangman
  MAX_GUESSES = 8

  attr_reader :referee, :guesser, :current_board
  attr_accessor :remaining_guesses

  def initialize(guesser, referee)
    @guesser = guesser
    @referee = referee
    @remaining_guesses = MAX_GUESSES
  end

  def self.prettify_board(board)
    board.map { |elem| elem == nil ? "_" : elem } * " "
  end

  def play
    secret_length = referee.pick_secret_word
    guesser.register_secret_length(secret_length)
    @current_board = [nil] * secret_length

    while @remaining_guesses > 0
      take_turn
      p Hangman.prettify_board(current_board)

      if won?
        puts "Guesser wins!"
        return
      end
    end

    puts "Word was #{referee.require_secret}"
    puts "Guesser loses!"

    nil
  end

  def take_turn
    guess = guesser.guess(current_board, remaining_guesses)
    indices = referee.check_guess(guess)
    update_board(guess, indices)
    @remaining_guesses -= 1 if indices.empty?

    guesser.handle_response(guess, indices)
  end

  def update_board(guess, indices)
    indices.each { |index| current_board[index] = guess }
  end

  def won?
    current_board.all?
  end
end

class HumanPlayer
  def register_secret_length(length)
    puts "Secret word is #{length} letters long"
  end

  def handle_response(guess, response)
    puts "Found #{guess} at positions #{response}}"
  end

  def guess(board, remaining_guesses)
    p "Number of guesses left is #{remaining_guesses}"
    p Hangman.prettify_board(board)
    puts "Input guess:"
    gets.chomp
  end

  def pick_secret_word
    puts "Think of a secret word. How long is it?"

    begin
      Integer(gets.chomp)
    rescue ArgumentError
      puts "Enter a vlid length."
      retry
    end
  end

  def check_guess(guess)
    puts "Player guessed #{guess}"
    puts "What positions does that occur in?"

    positions = gets.chomp.split(",").map { |str| Integer(str) }
  end

  def require_secret
    puts "What word were you thinking of?"
    gets.chomp
  end
end

class ComputerPlayer
  attr_reader :dictionary, :secret_word
  attr_accessor :dont_guess

  def self.player_with_dict_file(dict_file_name)
    ComputerPlayer.new(File.readlines(dict_file_name).map(&:chomp))
  end

  def initialize(dictionary)
    @dictionary = dictionary
    @dont_guess = []

  end

  def pick_secret_word
    @secret_word = dictionary.sample

    @secret_word.length
  end

  def check_guess(guess)
    response = []

    secret_word.split("").each_with_index do |letter, index|
      response << index if letter == guess
    end

    response
  end

  def register_secret_length(length)
    @candidate_words = dictionary.dup

    @candidate_words.select! { |word| word.length == length }
  end

  def require_secret
    secret_word
  end

  def guess(board, remaining_guesses)
    #Guesses a letter at random
    guess = ("a".."z").to_a.sample
    while dont_guess.include? guess
      guess = ("a".."z").to_a.sample
    end
    guess
  end

  def handle_response(guess, response_indices)
    dont_guess << guess
  end

end

if __FILE__ == $PROGRAM_NAME
  p "Guesser: Computer (yes/no)?"
  if gets.chomp == "yes"
    guesser = ComputerPlayer.player_with_dict_file("dictionary.txt")
  else
    guesser = HumanPlayer.new
  end

  p "Referee: Computer (yes/no)?"
  if gets.chomp == "yes"
    referee = ComputerPlayer.player_with_dict_file("dictionary.txt")
  else
    referee = HumanPlayer.new
  end

  Hangman.new(guesser, referee).play
end
