require 'debugger'

class Piece
  attr_reader :color, :type, :board

  def initialize(color, position, board, type)
    @color = color
    @position = position
    @board = board
    @type = type
  end

  def valid_move?(coord)
    valid_trans = valid_transformation?(coord)
    dest_has_object = dest_has_object?(coord)
    if dest_has_object
      dest_same_color = dest_same_color?(coord)
    end

    if valid_trans
      if dest_has_object && dest_same_color
        return false
      else
        return true
      end
    else
      return false
    end
  end

  def dest_has_object?(coord)
    dest_piece = @board.board[coord[0]][coord[1]]
    dest_piece == '__' ? false : true
  end

  def dest_same_color?(coord)
    dest_piece = @board.board[coord[0]][coord[1]]
    dest_piece.color == @color ? true : false
  end

  def make_move(coord)
    @board.board[coord[0]][coord[1]] = self
    @board.board[@position[0]][@position[1]] = "__"
    @position = coord
  end

  def within_bounds?(current_pos)
    if (current_pos[0] < 0) or (current_pos[0] > 7) or (current_pos[1] < 0) or (current_pos[1] > 7)
      return false
    else
      return true
    end
  end
end

class SlidingPiece < Piece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    #@valid_trans = []
  end

  def valid_transformation?(coord)
    valid_moves = find_valid_moves(coord)
    valid_moves.include?(coord) ? true : false
  end

  def find_valid_moves(coord)
    valid_moves = []
    @valid_trans.each do |trans|
      current_pos = @position.dup

      while true
        current_pos[0] += trans[0]
        current_pos[1] += trans[1]
        break unless within_bounds?(current_pos)
        #puts "#{current_pos[0]} #{current_pos[1]} #{within_bounds?(current_pos)}"

        path_contents = @board.board[current_pos[0]][current_pos[1]]
        if path_contents == "__"
          valid_moves << current_pos.dup
          next
        else #there's an object
          if dest_same_color?(current_pos)
            #don't add to valid_moves
          else
            valid_moves << current_pos.dup
          end
          break
        end
      end
    end

    valid_moves
  end
end

class Queen < SlidingPiece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    @valid_trans = [ [0, -1], [-1, -1], [-1, 0], [-1, 1],
                   [0, 1], [1, 1], [1, 0], [1, -1]]
  end
end

class Rook < SlidingPiece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    @valid_trans = [ [0, -1], [-1, 0], [0, 1], [1, 0] ]
  end
end


class Bishop < SlidingPiece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    @valid_trans = [ [-1, -1], [-1, 1], [1, 1], [1, -1] ]
  end
end

class Pawn < Piece
  def initialize(color, position, board, type)
    super(color, position, board, type)
  end

  def valid_transformation?(coord)
    valid_moves = find_valid_moves(coord)
    valid_moves.include?(coord) ? true : false
  end

  def object_of_same_color?(coord)
    piece = @board.board[coord[0]][coord[1]]
    if piece == "__"
      return false
    else #there's a piece there
      if piece.color == @color
        return true
      else
        return false
      end
    end
  end

  def object_present?(coord)
    piece = @board.board[coord[0]][coord[1]]
    if piece == "__"
      puts "object not present #{coord}"
      return false
    else
      puts "object present #{coord}"
      return true
    end
  end

  def find_valid_moves(coord)
    all_valid_moves = []
    valid_vert_trans = []
    valid_diag_trans = []
    if @color == :W
      valid_vert_trans = [ [-1, 0] ]
      valid_diag_trans = [[-1, -1], [-1, 1]]
    else #player color = :B
      valid_vert_trans = [ [ 1, 0] ]
      valid_diag_trans = [[1, -1], [1, 1]]
    end

    valid_vert_trans.each do |trans|
      new_coord = [ @position[0] + trans[0], @position[1] + trans[1] ]
      puts "current position: #{@position}"
      puts "vert_trans: #{trans}"
      puts "vert_trans_coord to evaluate: #{new_coord}"
      if within_bounds?(new_coord) && !object_present?(new_coord)
        all_valid_moves << new_coord
      end
    end

    valid_diag_trans.each do |trans|
      new_coord = [ @position[0] + trans[0], @position[1] + trans[1] ]
      if within_bounds?(new_coord) && !object_of_same_color?(new_coord) && object_present?(new_coord)
        all_valid_moves << new_coord
      end
    end

    puts "all_valid_moves: #{all_valid_moves}"
    all_valid_moves
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
      puts "White's turn"
      player1.make_move
      @board.print_board
      puts "Black's turn"
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
      piece = Pawn.new(:B, coord, self, :P)
      @board[coord[0]][coord[1]] = piece
    end

    #populate white pawns
    white_pawns_start_coords = [ [6,0], [6,1], [6,2],
                      [6,3], [6,4], [6,5], [6,6],
                      [6,7] ]
    white_pawns_start_coords.each do |coord|
      piece = Pawn.new(:W, coord, self, :P)
      @board[coord[0]][coord[1]] = piece
    end

    #Test piece:
    @board[5][4] = Queen.new(:B, [5,4], self, :Q)
    @board[5][6] = Queen.new(:W, [5,6], self, :Q)

#
#     #populate queens
#     @board[0][4] = Queen.new(:B, [0,4], self, :Q)
#     @board[7][4] = Queen.new(:W, [7,4], self, :Q)
#
#     #populate bishops
#     @board[0][2] = Bishop.new(:B, [0,2], self, :B)
#     @board[0][5] = Bishop.new(:B, [0,5], self, :B)
#     @board[7][2] = Bishop.new(:W, [7,2], self, :B)
#     @board[7][5] = Bishop.new(:W, [7,5], self, :B)

    # #populate rooks
    # @board[0][0] = Rook.new(:B, [0,0], self, :R)
    # @board[0][7] = Rook.new(:B, [0,7], self, :R)
    # @board[7][0] = Rook.new(:W, [7,0], self, :R)
    # @board[7][7] = Rook.new(:W, [7,7], self, :R)
  end

  def print_board
    puts "   0  1  2  3  4  5  6  7"
    @board.each_with_index do |row, i|
      output_row = row.map do |piece|
        if piece == "__"
          "__"
        else
          "#{piece.color}#{piece.type}"
        end
      end
      puts "#{i}  #{output_row.join(" ")}"
      puts "" #empty line
    end
    nil
  end
end

Game.new.play