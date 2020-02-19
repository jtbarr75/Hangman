class Game
  attr_reader :word, :line, :wrong_guesses, :wrong_guesses_remaining, :game_over

  def initialize(word = select_word, line = [], wrong_guesses = [], wrong_guesses_remaining = 7)
    @word = word
    @line = line
    @wrong_guesses = wrong_guesses
    @wrong_guesses_remaining = wrong_guesses_remaining
    @game_over = false
    word.length.times {line.push "_"} if line == []
  end
    
  def select_word
    dictionary = File.readlines("5desk.txt")
    dictionary.select! {|word| word.length.between?(7,12)}
    word = dictionary[rand(dictionary.length)].chomp
  end

  def get_input
    puts "Guess a letter"
    input = gets.chomp.downcase
    until input =~ /^[a-z]$/ || input == 'quit'
      save if input == 'save'
      
      puts "Guess a letter"
      input = gets.chomp.downcase
    end
    @game_over = true if input == 'quit'
    input
  end

  def print_man
    hangman = %Q(
       ________
      |        |
      #{@wrong_guesses_remaining < 7 ? "0" : " "}        |
     #{@wrong_guesses_remaining < 6 ? "/" : " "}#{@wrong_guesses_remaining < 5 ? "|" : " "}#{@wrong_guesses_remaining < 4 ? "\\" : " "}       |
      #{@wrong_guesses_remaining < 3 ? "|" : " "}        |
     #{@wrong_guesses_remaining < 2 ? "/" : " "} #{@wrong_guesses_remaining < 1 ? "\\" : " "}       |
               |
          ---------
    )
    puts hangman
  end

  def check_for_win
    unless @line.include? "_"
      @game_over = true 
      print_man
      puts @line.join " "
      puts "You Win!"
    end
  end

  def check_for_loss
    if @wrong_guesses_remaining == 0
      @word.split("").each_with_index do |letter, index|
        @line[index] = letter 
      end
      print_man
      puts @line.join " "
      puts "He's dead. You lose."
      @game_over = true
    end
  end

  def start_game
    if Dir.exist?('saves')
      puts "Would you like to continue from a save file? y/n"
      input = gets.chomp
      until input =~ /^[ynYN]/
        puts "Please put something like yeah or nah"
        input = gets.chomp
      end
    
      input =~ /^[yY]/ ? load : new_game
    else
      new_game
    end
  
    game_loop
  end

  def new_game
    puts "Let's play Hangman! I'm thinking of a word."
    puts "Type save at any time to save your progress"
  end

  def check(guess)
    correct_guess = false
      @word.split("").each_with_index do |letter, index|
        if letter == guess
          @line[index] = letter 
          correct_guess = true
        end
      end

      unless correct_guess
        @wrong_guesses_remaining -= 1 
        @wrong_guesses.push guess
      end

      check_for_win
      check_for_loss
  end

  def game_loop
    until @game_over
      puts "Wrong guesses: #{@wrong_guesses.join(", ")}" unless @wrong_guesses == []
      print_man
      puts @line.join " "
      guess = get_input

      check(guess)
    end
  end

  def save
    Dir.mkdir('saves') unless Dir.exist? 'saves'
    File.open("saves/saved_game#{Dir.entries('saves').length-1}", 'w+') do |f|
      Marshal.dump(self, f)
    end
    puts 'Game saved.'
  end
  
  def load
    puts "Please choose from the following saves:"
    choices = [0]
    Dir.entries('saves').each_with_index do |fname, index|
      unless fname == ".." || fname == "."
        choices << index
        File.open("saves/#{fname}") do |file|
          game = Marshal.load(file)
          puts "#{index}. #{game.line.join(" ")} wrong guesses remaining: #{game.wrong_guesses_remaining}"
        end
      end
    end

    save_num = gets.chomp
    until save_num.to_i.between?(1,choices.length)
      puts "Choose a save file from 1 - #{choices.length}"
      save_num = gets.chomp
    end

    File.open("saves/saved_game#{save_num}") do |file|
      game = Marshal.load(file)
      @word = game.word
      @line = game.line
      @wrong_guesses = game.wrong_guesses
      @wrong_guesses_remaining = game.wrong_guesses_remaining
      puts "Game loaded successfully."
    end
  end
  
end

game = Game.new
game.start_game