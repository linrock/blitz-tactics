class Puzzles

  SET_SIZE = 20

  PUZZLES = [

    # Source: 2.1.5.4
    {
      :fen => "3r3Q/4kp2/3N2p1/8/8/2P5/5KPP/8 w - - 0 1",
      :solution => [
        ["h8", "d8"],
        ["e7", "d8"],
        ["d6", "f7"]
      ]
    },

    # Source: 2.1.8.9
    {
      :fen => "2r2b1r/pp1k1ppp/5p2/3N4/3pq3/8/PPP2QPP/2KR3R w KQkq - 0 1",
      :solution => [
        ["d5", "f6"],
        ["g7", "f6"],
        ["d1", "d4"],
        ["e4", "d4"],
        ["f2", "d4"]
      ]
    },

    # Source: 2.1.11.3
    {
      :fen => "8/8/4q3/3pNRp1/6p1/5pP1/1P3K1k/8 w - - 0 1",
      :solution => [
        ["f5", "f6"],
        ["e6", "f6"],
        ["e5", "g4"]
      ]
    },

    # Source: 2.1.8.12
    {
      :fen => "r1b3k1/p3q1pp/2p1p3/b2pNr2/6Q1/P1N5/1PP2PPP/4RRK1 w KQkq - 0 1",
      :solution => [
        %w( e5 c6 ),
        %w( e7 c7 ),
        %w( c6 e7 ),
        %w( c7 e7 ),
        %w( g4 f5 )
      ]
    },

    # Source: 2.1.8.10
    {
      :fen => "2k4r/1bpq2b1/p1np2p1/1p1N4/4QP1p/1B5P/PPP2BP1/1K1R4 w KQkq - 0 1",
      :solution => [
        %w( d5 b6 ),
        %w( c7 b6 ),
        %w( b3 e6 ),
        %w( d7 e6 ),
        %w( e4 e6 )
      ]
    },

    # Source: 2.2.10.7
    {
      :fen => "r4rk1/2qn2pp/p3b3/1pp1pn2/7N/2P1B3/PPB2PPP/3QR1KR w KQkq - 0 1",
      :solution => [
				%w( h4 f5 ),
				%w( e6 f5 ),
				%w( c2 f5 ),
				%w( f8 f5 ),
				%w( d1 d5 ),
				%w( f5 f7 ),
				%w( d5 a8 )
      ]
    },

    # Source: 2.2.5.3
    {
      :fen => "r4rk1/ppn1q3/3p2pp/2pP1b2/2P1N3/2P1B3/P5QP/R4R1K w KQkq - 0 1",
      :solution => [
        %w( f1 f5 ),
        %w( f8 f5 ),
        %w( g2 g6 ),
        %w( e7 g7 ),
        %w( g6 f5 )
      ]
    }

  ]

  def self.shuffled
    PUZZLES.shuffle
  end

end
