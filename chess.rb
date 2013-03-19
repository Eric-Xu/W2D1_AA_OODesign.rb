class Pawn
  attr_reader :color, :type, :board

  def initialize(color, position, board)
    @color = color
    @position = position
    @board = board
    @type = :P
  end

  def valid_move?(coord)
    valid_trans = []
    if @color == :W
      valid_trans = [-1, 0]
    else #player color = :B
      valid_trans = [ 1, 0]
    end
    if [@position[0] + valid_trans[0],
        @position[1] + valid_trans[1]] == coord
      true
    else
      false
    end
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
    player1 = Player.new(@board, :W)
    player2 = Player.new(@board, :B)
    @board.print_board

    until game_over
      puts "Player with white pieces' turn"
      player1.make_move
      @board.print_board
      puts "Player with black pieces' turn"
      player2.make_move
      @board.print_board
    end
  end
end

class Player
  attr_accessor :color

  def initialize(board, color)
    @board = board
    @color = color
  end

  def make_move
    while true
      start_coord, end_coord = collect_input
      if @board.board[ start_coord[0] ] [ start_coord[1] ] == '__'
        puts "Please select a non-empty coordinate"
        next
      end

      piece = @board.board[ start_coord[0] ] [ start_coord[1] ]

      if piece.color != @color
        puts "Please select a piece of the correct color"
        next
      elsif !piece.valid_move?(end_coord)
        puts "Invalid move; please try again"
        next
      end

      piece.make_move([ end_coord[0], end_coord[1] ])
      break
    end
  end

  def collect_input
    puts "Enter coord of piece to move:"
    start_coord = read_keyboard_input
    puts "Enter destination coord:"
    end_coord = read_keyboard_input
    return start_coord, end_coord
  end

  def read_keyboard_input
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