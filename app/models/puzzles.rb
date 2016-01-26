class Puzzles

  PUZZLES = [

    {
      :fen => "3r3Q/4kp2/3N2p1/8/8/2P5/5KPP/8 w - - 0 1",
      :solution => [
        ["h8", "d8"],
        ["e7", "d8"],
        ["d6", "f7"]
      ]
    },

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

    {
      :fen => "8/8/4q3/3pNRp1/6p1/5pP1/1P3K1k/8 w - - 0 1",
      :solution => [
        ["f5", "f6"],
        ["e6", "f6"],
        ["e5", "g4"]
      ]
    }

  ]

end
