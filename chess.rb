#encoding: utf-8

#Note to reviewers:
#Things we're planning on refactoring:
#1. change "__" in board to nil
#2. eliminate 'type' from Piece class as it's now redundant

require 'debugger'

class Piece
  attr_reader :color, :type, :board
  attr_accessor :position

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
    # KL: I would shorten this to
    # if valid_trans
    #   true unless dest_has_object && dest_same_color
    # end
    #
    # false
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

  #redundant from valid_move?
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
    # KL: again here, just do 'false if ....'
    # use || not 'or'
    if (current_pos[0] < 0) or (current_pos[0] > 7) or
        (current_pos[1] < 0) or (current_pos[1] > 7)
      return false
    else
      return true
    end
  end
end

class SlidingPiece < Piece
  def initialize(color, position, board, type)
    super(color, position, board, type)
  end

  def valid_transformation?(coord)
    valid_moves = find_valid_moves
    valid_moves.include?(coord) ? true : false
  end
  # KL: this method should be broken up a bit
  def find_valid_moves
    valid_moves = []
    @valid_trans.each do |trans|
      current_pos = @position.dup

      while true
        current_pos[0] += trans[0]
        current_pos[1] += trans[1]

        break unless within_bounds?(current_pos)

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

class SteppingPiece < Piece
  def initialize(color, position, board, type)
    super(color, position, board, type)
  end

  def valid_transformation?(coord)
    valid_moves = find_valid_moves
    valid_moves.include?(coord) ? true : false
  end

  def find_valid_moves
    #KL: this loooks like it borrows a lot of code from your other find_valid_moves
    # you should factor that out and put it in the Piece class
    valid_moves = []
    @valid_trans.each do |trans|
      current_pos = @position.dup

      current_pos[0] += trans[0]
      current_pos[1] += trans[1]
      next unless within_bounds?(current_pos)

      path_contents = @board.board[current_pos[0]][current_pos[1]]
      if path_contents == "__"
        valid_moves << current_pos.dup
      else #there's an object
        if dest_same_color?(current_pos)
          #don't add to valid_moves
        else
          valid_moves << current_pos.dup
        end
        next
      end
    end

    valid_moves
  end
end

class King < SteppingPiece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    @valid_trans = [ [0, -1], [-1, -1], [-1, 0], [-1, 1],
                   [0, 1], [1, 1], [1, 0], [1, -1]]
  end
end

class Knight < SteppingPiece
  def initialize(color, position, board, type)
    super(color, position, board, type)
    @valid_trans = [ [-1, -2], [-2, -1], [-2, 1], [-1, 2],
                   [1, 2], [2, 1], [2, -1], [1, -2]]
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
    valid_moves = find_valid_moves
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
      return false
    else
      return true
    end
  end

  def find_valid_moves
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
      if within_bounds?(new_coord) && !object_present?(new_coord)
        all_valid_moves << new_coord
      end
    end

    valid_diag_trans.each do |trans|
      new_coord = [ @position[0] + trans[0], @position[1] + trans[1] ]
      if within_bounds?(new_coord) && !object_of_same_color?(new_coord) &&
              object_present?(new_coord)
        all_valid_moves << new_coord
      end
    end

    all_valid_moves
  end
end

class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end

  def play
    # KL: lot of redundant code here
    # put the play blocks into a player_turn method or something
    game_over = false
    player1 = Player.new(@board, :W)
    player2 = Player.new(@board, :B)
    @board.print_board

    until game_over
      puts "White's turn"
      while true
        player1.make_move
        if @board.check_mate?(:B)
          @board.print_board
          print_message("Checkmate!")
          return nil
        elsif @board.in_check?(:W)
          print_message("Check: move not allowed!")
          player1.revert_move
          next
        elsif @board.in_check?(:B)
          print_message("Check!")
          break
        else
          break
        end
      end
      @board.print_board
      puts "Black's turn"
      while true
        player2.make_move
        if @board.check_mate?(:W)
          @board.print_board
          print_message("Checkmate!")
          return nil
        elsif @board.in_check?(:B)
          print_message("Check: move not allowed!")
          player2.revert_move
          next
        elsif @board.in_check?(:W)
          print_message("Check!")
          puts "Check!"
          break
        else
          break
        end
      end
      @board.print_board
    end

    print_message("Game over")
  end
end

def print_message(message)
  puts ""
  puts message
  puts ""
end

class Board
  attr_accessor :board

  def initialize
    @board = [ [],[],[],[],[],[],[],[] ]
    create_initial_board_state
    @start_object = nil
    @start_coord = []
    @end_object = nil
    @end_coord = []
  end
  # KL: this method is wayyy too long
  def check_mate?(color)
    king = nil
    poss_king_moves = []
    same_col_objects = []

    @board.flatten.each do |square|
      if square == "__"
        #don't do anything
      else #has object
        if square.type == :K and square.color == color
          king = square
        else
          if square.color == color
            same_col_objects << square
          end
        end
      end
    end

    all_king_moves_result_in_check = true

    king.find_valid_moves.each do |coord|
      poss_king_moves << coord
    end

    if !in_check?(color)
      all_king_moves_result_in_check = false
    end

    #TODO: refactor the below two blocks into helper method
    poss_king_moves.each do |end_coord|
      @start_object = king
      @start_coord = king.position.dup
      @end_object = @board[ end_coord[0] ] [ end_coord[1] ] #was dup

      king.make_move([ end_coord[0], end_coord[1] ])
      if !in_check?(color)
        all_king_moves_result_in_check = false
      end
      revert_move
    end

    all_buddy_moves_result_in_check = true

    #check if any moves from same color pieces eliminate checkmate
    same_col_objects.each do |piece|
      piece.find_valid_moves.each do |end_coord|
        @start_object = piece
        @start_coord = piece.position.dup
        @end_object = @board[ end_coord[0] ] [ end_coord[1] ] #was dup
        @end_coord = end_coord.dup

        piece.make_move([ end_coord[0], end_coord[1] ])
        if !in_check?(color)
          all_buddy_moves_result_in_check = false
        end
        revert_move
      end
    end

    all_king_moves_result_in_check and all_buddy_moves_result_in_check
  end

  def revert_move
    @start_object.position = @start_coord
    @board[ @start_coord[0] ] [ @start_coord[1] ] = @start_object
    @board[ @end_coord[0] ] [ @end_coord[1] ] = @end_object
  end

  def in_check?(color)
    king = nil
    opp_col_objects = []
    @board.flatten.each do |square|
      if square == "__"
        #don't do anything
      else #has object
        if (square.type == :K) and (square.color == color)
          king = square
        end
        if square.color != color
          opp_col_objects << square
        end
      end
    end

    possible_moves = []
    opp_col_objects.each do |piece|
      piece.find_valid_moves.each do |coord|
        possible_moves << coord
      end
    end

    if possible_moves.include?(king.position)
      return true
    else
      return false
    end
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
    # KL: you should be able to set up a base order of pieces, loop through the board
    # and place the pieces
    #populate queens
    @board[0][4] = Queen.new(:B, [0,4], self, :Q)
    @board[7][4] = Queen.new(:W, [7,4], self, :Q)

    #populate bishops
    @board[0][2] = Bishop.new(:B, [0,2], self, :B)
    @board[0][5] = Bishop.new(:B, [0,5], self, :B)
    @board[7][2] = Bishop.new(:W, [7,2], self, :B)
    @board[7][5] = Bishop.new(:W, [7,5], self, :B)

    #populate rooks
    @board[0][0] = Rook.new(:B, [0,0], self, :R)
    @board[0][7] = Rook.new(:B, [0,7], self, :R)
    @board[7][0] = Rook.new(:W, [7,0], self, :R)
    @board[7][7] = Rook.new(:W, [7,7], self, :R)

    #populate knights
    @board[0][1] = Knight.new(:B, [0,1], self, :N)
    @board[0][6] = Knight.new(:B, [0,6], self, :N)
    @board[7][1] = Knight.new(:W, [7,1], self, :N)
    @board[7][6] = Knight.new(:W, [7,6], self, :N)

    #populate kings
    @board[0][3] = King.new(:B, [0,3], self, :K)
    @board[7][3] = King.new(:W, [7,3], self, :K)
  end

  def print_board
    white = {}
    white[:K] = "♔"
    white[:Q] = "♕"
    white[:R] = "♖"
    white[:B] = "♗"
    white[:N] = "♘"
    white[:P] = "♙"

    black = {}
    black[:K] = "♚"
    black[:Q] = "♛"
    black[:R] = "♜"
    black[:B] = "♝"
    black[:N] = "♞"
    black[:P] = "♟"

    puts "    0   1   2   3   4   5   6   7"
    puts ""
    @board.each_with_index do |row, i|
      output_row = row.map do |piece|
        if piece == "__"
          "___"
        else
          if piece.color == :W
            " #{white[piece.type]} "
          else
            " #{black[piece.type]} "
          end
        end
      end
      puts "#{i}  #{output_row.join(" ")}"
      puts "" #empty line
    end
    nil
  end
end

class Player
  attr_accessor :color

  def initialize(board, color)
    @board = board
    @color = color
    @start_object = nil
    @start_coord = []
    @end_object = nil
    @end_coord = []
  end

  def revert_move
    @start_object.position = @start_coord
    @board.board[ @start_coord[0] ] [ @start_coord[1] ] = @start_object
    @board.board[ @end_coord[0] ] [ @end_coord[1] ] = @end_object
  end

  def make_move
    while true
      # KL: don't need to use 'next' like this in a while loop
      start_coord, end_coord = collect_input
      if @board.board[ start_coord[0] ] [ start_coord[1] ] == '__'
        puts "Please select a non-empty coordinate"
        next
      end

      piece = @board.board[ start_coord[0] ] [ start_coord[1] ]
      # KL: these should be put in a validation method
      if piece.color != @color
        puts "Please select a piece of the correct color"
        next
      elsif !piece.valid_move?(end_coord)
        puts "Invalid move; please try again"
        next
      end

      @start_object = piece
      @start_coord = start_coord.dup
      @end_object = @board.board[ end_coord[0] ] [ end_coord[1] ].dup
      @end_coord = end_coord.dup

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

Game.new.play