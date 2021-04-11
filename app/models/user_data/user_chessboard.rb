# custom user chessboard colors
#
class UserChessboard < ActiveRecord::Base
  belongs_to :user

  HEX_REGEX = /\A#[0-9A-F]{6}\z/

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
      send("#{field}=", send(field).upcase) if field.present?
    end
  end
end
