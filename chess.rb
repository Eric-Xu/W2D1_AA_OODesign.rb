class Pawn
  attr_reader :color, :type, :board

  def initialize(color, position, board)
    @color = color
    @position = position
    @board = board
    @type = :P
  end

  def valid_move?(coord)

  end

  def make_move(coord)
    @board.board[coord[0]][coord[1]] = self
    @board.board[@position[0]][@position[1]] = "__"
    @position = coord
  end
end


class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end

  def play
    game_over = false
    player1 = Player.new
    player2 = Player.new

    until game_over
      player1.make_move
      player2.make_move
    end
  end
end

class Player

  piece = @board.board[start_coord[0]][start_coord[1]]
  piece.make_move([ end_coord[0], end_coord[1] ])
  @board.print_board
  puts ""

  def make_move
    puts "Enter coord of piece to move:"
    start_coord = collect_input
    puts "Enter destination coord:"
    end_coord = collect_input
  end

  def collect_input
    gets.chomp.split(" ").map! { |el| el.to_i }
  end
end

class Board
  attr_accessor :board

  def initialize
    @board = [ [],[],[],[],[],[],[],[] ]
    create_initial_board_state
  end

  def create_initial_board_state
    #populate underscores for blank board spaces
    (0..7).each do |row|
      (0..7).each do |pos|
        @board[row][pos] = "__"
      end
    end

    #populate black pawns
    black_pawns_start_coords = [ [1,0], [1,1], [1,2],
                      [1,3], [1,4], [1,5], [1,6],
                      [1,7] ]
    black_pawns_start_coords.each do |coord|
      piece = Pawn.new(:B, coord, self)
      @board[coord[0]][coord[1]] = piece
    end

    #populate white pawns
    white_pawns_start_coords = [ [6,0], [6,1], [6,2],
                      [6,3], [6,4], [6,5], [6,6],
                      [6,7] ]
    white_pawns_start_coords.each do |coord|
      piece = Pawn.new(:W, coord, self)
      @board[coord[0]][coord[1]] = piece
    end
  end

  def print_board
    @board.each do |row|
      output_row = row.map do |piece|
        if piece == "__"
          "__"
        else
          "#{piece.color}#{piece.type}"
        end
      end
      puts output_row.join(" ")
      puts "" #empty line
    end
    return nil #for display
  end
end