class Hangman
  MAX_GUESSES = 8

  attr_reader :referee, :guesser, :current_board
  attr_accessor :remaining_guesses

  def initialize(guesser, referee)
    @guesser = guesser
    @referee = referee
    @remaining_guesses = MAX_GUESSES
  end

  def play
    secret_length = referee.pick_secret_word
    guesser.register_secret_length(secret_length)
    @current_board = [nil] * secret_length

    while @remaining_guesses > 0
      take_turn

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
    p board
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

  def self.player_with_dict_file(dict_file_name)
    ComputerPlayer.new(File.readlines(dict_file_name).map(&:chomp))
  end

  def initialize(dictionary)
    @dictionary = dictionary
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

end

if __FILE__ == $PROGRAM_NAME
  guesser = HumanPlayer.new
  referee = ComputerPlayer.player_with_dict_file("dictionary.txt")

  Hangman.new(guesser, referee).play
end
