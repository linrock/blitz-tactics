# custom user chessboard colors
#
class UserChessboard < ActiveRecord::Base
  belongs_to :user

  HEX_REGEX = /\A#[0-9A-F]{6}\z/

  PIECE_SETS = %w[
    alpha anarcandy caliente california cardinal cburnett celtic chess7
    chessnut companion cooke disguised dubrovny fantasy firi fresca gioco
    governor horsey icpieces kiwen-suwi kosal leipzig letter maestro merida
    monarchy mono mpchess pirouetti pixel reillycraig rhosgfx riohacha
    shapes spatial staunty tatiana xkcd
  ].freeze

  COLOR_FIELDS = [
    :light_square_color,
    :dark_square_color,
    :selected_square_color,
    :opponent_from_square_color,
    :opponent_to_square_color,
  ]

  before_validation :nullify_blank_colors
  before_validation :capitalize_hex_colors

  COLOR_FIELDS.each do |color|
    validates color, format: HEX_REGEX, allow_nil: true
  end

  validates :piece_set, inclusion: { in: PIECE_SETS }, allow_nil: true

  def effective_piece_set
    piece_set.present? ? piece_set : 'cburnett'
  end

  # returns nil if no styles defined, CSS string otherwise
  def to_css
    styles = []
    %w( chessboard mini-chessboard ).each do |board_class|
      if light_square_color
        styles << "
          .#{board_class} .square.light {
            background: #{light_square_color} !important;
          }
          .#{board_class} .square .square-label.dark {
            color: #{light_square_color} !important;
          }
          .cg-wrap.orientation-white coords.ranks coord:nth-child(2n + 1) {
            color: #{light_square_color} !important;
          }
          .cg-wrap.orientation-white coords.files coord:nth-child(2n + 1) {
            color: #{light_square_color} !important;
          }
          .cg-wrap.orientation-black coords.ranks coord:nth-child(2n) {
            color: #{light_square_color} !important;
          }
          .cg-wrap.orientation-black coords.files coord:nth-child(2n) {
            color: #{light_square_color} !important;
          }
        "
      end
      if dark_square_color
        styles << "
          .#{board_class} .square.dark {
            background: #{dark_square_color} !important;
          }
          .#{board_class} .square .square-label.light {
            color: #{dark_square_color} !important;
          }
          .cg-wrap.orientation-white coords.ranks coord:nth-child(2n) {
            color: #{dark_square_color} !important;
          }
          .cg-wrap.orientation-white coords.files coord:nth-child(2n) {
            color: #{dark_square_color} !important;
          }
          .cg-wrap.orientation-black coords.ranks coord:nth-child(2n + 1) {
            color: #{dark_square_color} !important;
          }
          .cg-wrap.orientation-black coords.files coord:nth-child(2n + 1) {
            color: #{dark_square_color} !important;
          }
        "
      end
      if light_square_color || dark_square_color
        board_svg = %(
          <?xml version="1.0" encoding="UTF-8" standalone="no"?>
          <svg xmlns="http://www.w3.org/2000/svg" xmlns:x="http://www.w3.org/1999/xlink"
              viewBox="0 0 8 8" shape-rendering="crispEdges">
          <g id="a">
            <g id="b">
              <g id="c">
                <g id="d">
                  <rect width="1" height="1" fill="#{light_square_color || "#F3E4CF"}" id="e"/>
                  <use x="1" y="1" href="#e" x:href="#e"/>
                  <rect y="1" width="1" height="1" fill="#{dark_square_color || "#CEB3A2"}" id="f"/>
                  <use x="1" y="-1" href="#f" x:href="#f"/>
                </g>
                <use x="2" href="#d" x:href="#d"/>
              </g>
              <use x="4" href="#c" x:href="#c"/>
            </g>
            <use y="2" href="#b" x:href="#b"/>
          </g>
          <use y="4" href="#a" x:href="#a"/>
          </svg>
        ).strip
        base64_board_svg = Base64.encode64(board_svg).gsub(/\n/, '').strip
        styles << "
          cg-board {
            background-image: url('data:image/svg+xml;base64,#{base64_board_svg}');
          }
        "
      end
      if selected_square_color
        styles << "
          .#{board_class} .square[data-selected] {
            background: #{selected_square_color} !important;
          }
          cg-board square.selected {
            background: #{selected_square_color} !important;
          }
        "
      end
      if opponent_from_square_color
        styles << "
          .#{board_class} .square[data-from] {
            background: #{opponent_from_square_color} !important;
          }
          .#{board_class} .square.move-from {
            background: #{opponent_from_square_color} !important;
          }
          cg-board square.last-move.move-from {
            background-color: #{opponent_from_square_color} !important;
          }
        "
      end
      if opponent_to_square_color
        styles << "
          .#{board_class} .square[data-to] {
            background: #{opponent_to_square_color} !important;
          }
          .#{board_class} .square.move-to {
            background: #{opponent_to_square_color} !important;
          }
          cg-board square.last-move.move-to {
            background-color: #{opponent_to_square_color} !important;
          }
        "
      end
    end

    # Add piece set styles
    effective_set = effective_piece_set
    if effective_set != 'cburnett' && PIECE_SETS.include?(effective_set)
      add_piece_set_styles(styles, effective_set)
    end

    return unless styles.length > 0
    styles.join("\n").html_safe
  end

  private

  def nullify_blank_colors
    COLOR_FIELDS.each do |field|
      send("#{field}=", nil) unless field.present?
    end
  end

  def capitalize_hex_colors
    COLOR_FIELDS.each do |field|
      if send(field).present?
        send("#{field}=", send(field).upcase)
      end
    end
  end

  def add_piece_set_styles(styles, piece_set_name)
    pieces = %w[pawn bishop knight rook queen king]
    colors = %w[white black]
    
    pieces.each do |piece|
      colors.each do |color|
        piece_code = piece == 'knight' ? 'n' : piece[0] # knight -> n, others -> first letter
        piece_code = color == 'white' ? "w#{piece_code.upcase}" : "b#{piece_code.upcase}"
        
        # Try to read the SVG file and convert to base64
        svg_path = Rails.root.join("app/assets/images/pieces/#{piece_set_name}/#{piece_code}.svg")
        if File.exist?(svg_path)
          begin
            svg_content = File.read(svg_path)
            base64_svg = Base64.encode64(svg_content).gsub(/\n/, '').strip
            data_uri = "data:image/svg+xml;base64,#{base64_svg}"
            
            styles << "
              .cg-wrap piece.#{piece}.#{color} {
                background-image: url('#{data_uri}') !important;
              }
              .mini-chessboard .piece.#{piece}.#{color} {
                background-image: url('#{data_uri}') !important;
              }
            "
          rescue => e
            Rails.logger.warn "Failed to read SVG file #{svg_path}: #{e.message}"
          end
        else
          # Handle special cases like mono piece set
          if piece_set_name == 'mono'
            mono_svg_path = Rails.root.join("app/assets/images/pieces/#{piece_set_name}/#{piece_code[1]}.svg")
            if File.exist?(mono_svg_path)
              begin
                svg_content = File.read(mono_svg_path)
                base64_svg = Base64.encode64(svg_content).gsub(/\n/, '').strip
                data_uri = "data:image/svg+xml;base64,#{base64_svg}"
                
                styles << "
                  .cg-wrap piece.#{piece}.#{color} {
                    background-image: url('#{data_uri}') !important;
                  }
                  .mini-chessboard .piece.#{piece}.#{color} {
                    background-image: url('#{data_uri}') !important;
                  }
                "
              rescue => e
                Rails.logger.warn "Failed to read mono SVG file #{mono_svg_path}: #{e.message}"
              end
            end
          end
        end
      end
    end
  end
end
