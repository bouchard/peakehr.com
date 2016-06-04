# Read about factories at https://github.com/thoughtbot/factory_girl
ADDRESSES = %|4452 Middle Grove Gate, Economy, Britsh Columbia, V7W 1U0
1085 Sleepy Blossom Orchard, Smileyville, Manitoba, R8M 6Z7
3409 High Subdivision, Plenty Bears, Northwest Territories, X2G 1B1
9034 Cotton Highlands, Oral, New Brunswick, E2X 3Z7
8083 Sunny Parade, Prairie Queen, Alberta, T1M 5H7
1446 Heather Treasure Gardens, Cloud Chief, Alberta, T6P 7B7
7832 Crystal Panda Mall , Result, Nunavut, X1N 4W6
2527 Iron Corners, Fearing, Nunavut, X0I 3E8
413 Misty Wynd, Hardup, Ontario, M3T 3D0
5649 Silent Wagon Manor, Aleknagik, Nova Scotia, B2S 0V9
7417 Honey Spring Canyon, Lang, Alberta, T1O 4J0
8355 Round Willow Link, Cokeville, Prince Edward Island, C5E 1B1
7188 Foggy Townline, Table Rock, Yukon, Y7L 9Q3
1068 Cozy Anchor Woods, Crayon, Manitoba, R8Z 8U7
8074 Thunder Street, Silver King, Yukon, Y4R 7I3
6453 Colonial Key, Six Mile, Britsh Columbia, V4I 4E5
9383 Fallen Place, Rum Center, New Brunswick, E4V 8E5
343 Lost Cape, Burnt Cane Crossing, Alberta, T2N 7Y5
2260 Burning Moor, Moosup Valley, Nunavut, X1H 5S0
5349 Jagged Road, Henry Clay, New Brunswick, E5G 9H9
4487 Broad Beach, Eutaw, Saskatchewan, S5L 4A4
2399 Silver Alley, Plastic, Nova Scotia, B9K 7H3
1423 Tawny Mount, Chain of Rocks, Ontario, K9Y 7Y7
2847 Pleasant Horse Impasse, Pigeonroost, Prince Edward Island, C1J 5I9
2853 Velvet Shadow Plaza, Kooskooskie, Manitoba, R0G 4S4
9252 Cinder Bluff Nook, Kilkenny, Nunavut, X0A 8B1
8777 Stony Zephyr Chase, Sexsmith, Nova Scotia, B0Y 9B1
8292 Merry Square, Crackers Neck, Ontario, N1R 5N9
1389 Quiet Drive, Monday, Quebec, J3G 7L1
2983 Hidden Robin Park, Teulon, Nova Scotia, B8Y 4V2|.split("\n").map{ |a| a.split(",").join("\n") }

FactoryGirl.define do
  factory :demographics do
    sex { ['m', 'f'].sample }
    date_of_birth { rand(Time.local(1912, 1, 1)..3.months.ago) }
    occupation { COMMON_OCCUPATIONS.sample }
    phone_numbers {
      [
        {
          home: rand.to_s[2..11],
          work: rand.to_s[2..11]
        },
        {
          home: rand.to_s[2..11]
        },
        {}
        ].sample
    }
    addresses {
      [
        {
          home: ADDRESSES.sample,
          work: ADDRESSES.sample
        },
        {
          home: ADDRESSES.sample
        },
        {}
      ].sample
    }
  end
end
