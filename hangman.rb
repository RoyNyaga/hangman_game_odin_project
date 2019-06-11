require 'json'

class GameSave
  attr_accessor :secrete_word, :count, :correctness, :name, :session_name

  def initialize(secrete_word, count, correctness, name, session_name)
    @secrete_word = secrete_word
    @count        = count
    @correctness  = correctness
    @name         = name
    @session_name = session_name
  end

  def to_json
    JSON.dump ({
      :secrete_word => @secrete_word,
      :count => @count,
      :correctness => @correctness,
      :name => @name,
      :session_name => @session_name
    })
  end

  def self.from_json(string)
    data = JSON.load string
    self.new(data['secrete_word'], data['count'], data['correctness'], data['name'], data['session_name'])
  end

end


class Player
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def players_choice
    puts "ENTER YOUR GUESS"
    choice = ""
    loop do
      choice = gets.chomp
      break if choice =~ /\A\s*?[a-zA-Z]\s*?\Z/ ? true : false == true
      puts "ERROR : numbers, double letters and signs are not allowed"
      puts "ENTER A VALID SINGLE LETTER"
    end
    return choice.downcase 
  end 
  
end  


class Display
  attr_accessor :players_name, :word, :rounds

  def initialize(players_name, word, rounds)
    @word           = word 
    @rounds         = rounds
    @players_name   = players_name
  end 

  def instructions
    puts "######################################################################"
    puts "                                                                     #"
    puts "ONCE AGAIN YOUR ARE WELCOME #{players_name}!!!                       #"
    puts "MAKE SURE TO CAREFULLY READ THE INSTRUCTIONS BELLOW                  #"
    puts "---------------------------------------------------------------------#"
    puts "YOU HAVE 15 CHANCES TO GUESS ALL THE LETTERS OF THE SECRETE WORD     #"
    puts "AFTER EACH GUESS, A BOARD WILL DISPLAY HOW CORRECT YOUR GUESS WAS    #"
    puts "IN THE FORM '_________' WHERE THE NUMBER OF UNDERSCORES REPRESENTS   #"
    puts "THE LENGTH OF THE WORD AND IF YOUR GUESS WAS CORRECT, IT WILL BE     #"
    puts "INCLUDED IN THE RIGHT UNDERSCORE TO GIVE YOU HINTS ON WHAT THE WORD  #"
    puts "COULD BE. OK LET'S GET IT STARTED....................................#"
    puts ""   
  end

  def enter_choice
    puts "ENTER YOUR GUESS"
  end 

end 


def select_word

  word = ""
  loop do
    randomise = rand(60000)
    word = File.open("desk.txt", "r").readlines[randomise]
    break if word.length > 5 and word.length < 13
  end
  return word.downcase.strip
end 

def initialize_correctness(secrete_word)
  return "_" *secrete_word.length
end

def guess_belongs_to_word?(guess, secrete_word)
  return true if secrete_word.include?guess
  return false
end 

def match_guess_and_secrete_word(guess, secrete_word, correctness)

  length = secrete_word.length - 1

  for i in 0..length

    if correctness[i] == "_" and secrete_word[i] == guess   
      correctness[i] = guess
      break 
    end

  end
  return correctness
end

def save_game?(secrete_word, count, correctness, player)

  reply = ""
  print "DO YOU WANT TO SAVE YOUR PROGRESS?(Y/N)?:  "
  loop do
    reply = gets.chomp
    break if reply =~ /\A[YyNn]\Z/ ? true : false == true
    puts "INPUT ERROR:  enter either Y or N"
  end

  if reply.downcase == "y"
    print 'SAVING GAME AS:  '
    session_name = gets.chomp
    puts "Game saving............................."
    save_obj = GameSave.new(secrete_word, count, correctness, player.name, session_name)
    save_data = save_obj.to_json
    file = File.open("save_games.json", "w")
    file.puts save_data
    file.close
    return "y"
  else
    return "n"
  end

end 

def load_game?

  print "DO YOU WANT TO LOAD A SESSION?(Y/N)?:  "
  reply = ""
  loop do
    reply = gets.chomp
    break if reply =~ /\A[YyNn]\Z/ ? true : false == true
    puts "INPUT ERROR:  enter either Y or N"
  end
  return reply.downcase
end

def game(player, secrete_word, display)

  correctness = initialize_correctness(secrete_word)
  count = 0
  loop do
    if load_game? == "y"
      puts "LOADING GAME......................."
      retrieve_data = File.open("save_games.json", "r").readline
      saved_data = GameSave.from_json(retrieve_data)     
      correctness = saved_data.correctness
      secrete_word = saved_data.secrete_word
      count = saved_data.count
      puts "YOU ARE LEFT WITH #{15 - count} CHANCES AND THE CORRECTNESS OF YOUR GUESS IS '#{correctness}'"
    end 

    guess = player.players_choice
    if guess_belongs_to_word?(guess, secrete_word) == true
      correctness = match_guess_and_secrete_word(guess, secrete_word, correctness)
      count += 1
      puts correctness
      puts "CORRECT GUESS, YOU ARE LEFT WITH #{15 - count} CHANCES"
    else
      correctness = correctness = match_guess_and_secrete_word(guess, secrete_word, correctness)
      count += 1
      puts correctness
      puts "WRONG GUESS, YOU ARE LEFT WITH #{15 - count} CHANCES"
    end

    if correctness == secrete_word
      puts "CONGRATULATIONS #{player.name}, YOU WIN THE GAME"
      break
    end 
    
    break if count == 15

    if save_game?(secrete_word, count, correctness, player) == "y"
      puts "YOUR SESSION HAS BEEN SAVED"
      break
    end 
    
  end

  if count == 15
    puts "SORRY #{player.name}, YOU LOSE THE GAME"
    puts "THE SECRETE WORD WAS '#{secrete_word}'"
  end 

end  

def hangman
  puts "WELCOME FOR A HANGMAN GAME.\n please enter your name below to continue"
  players_name = gets.chomp
  player = Player.new(players_name)
  secrete_word = select_word
  puts secrete_word
  display = Display.new(players_name, secrete_word, 15)
  display.instructions
  game(player, secrete_word, display)
  
end 

hangman