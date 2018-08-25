require 'sinatra'
if development?
	require "sinatra/reloader"
end

enable :sessions

dictionary = File.read("5desk wordlist.txt")
dictionary = dictionary.split


get '/' do
  redirect to '/new'  if session["game"].nil?
  redirect to '/won'  if session["game"].show_correct == session["game"].word
  redirect to '/lost' if session["game"].misses.length >= 8
  puts session["game"].show_correct
  guess = session["game"].show_correct
  erb :index, :locals => {:guess => guess }
end

get '/new' do
  session["game"] = Hangman.new("" , dictionary)
  print  "new:  "
  puts session["game"]
  redirect to '/'
end

get '/won' do
  erb :winner
end

get '/lost' do
  erb :loser
end

post '/guess' do
  guess = params["guess"]
  session["game"].guess(guess)
  redirect to '/'
end


class Hangman
  attr_reader :misses
  attr_reader :word
  def initialize(player, dictionary)
    @player = player
    @word = dictionary.select{|word| word.length >= 5 && word.length <= 12 }.sample
    @misses = []
    @correct_letters = []
  end

  def guess(letter)
    return false if letter.nil?
    letter = letter.downcase
    if letter.length == 1  && ((@misses+@correct_letters).nil? || !(@misses+@correct_letters).include?(letter))
        @word.chars.include?(letter) ? @correct_letters << letter : @misses << letter
        return true
    end
    false
  end

  def show_correct
    known = @word.chars.map { |letter| @correct_letters.include?(letter) ? letter : "_"   }.join
    known
  end


  def show_misses
    misses_string = ""
    # @misses.each { |miss| misses_string += "\e[9m#{miss}\e[0m " }
    @misses.each { |miss| misses_string += "<strike>#{miss}</strike> " ; print "\e[9m#{miss}\e[0m "}
    puts ""
    puts "#{@misses.length} of 8 misses"
    misses_string

  end

end

puts "lets play Hangman."
puts "8 incorrect guesses and you lose"
