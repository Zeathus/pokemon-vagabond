def pbStadiumCups

  titles = []
  descriptions = []
  stats = [] # [max_level, difficulty]
  trainers = [] # [type, name, party, win, *before, *after]

  titles.push("Tutorial")
  descriptions.push("Get used to the Stadium battles with this Tutorial Cup.")
  stats.push([20,1])
  trainers.push([
    [:YOUNGSTER, "Ichi", 0],
    [:LASS, "Ni", 0],
    [:PRESCHOOLER_M, "San", 0],
    [:SCHOOLBOY, "Yon", 0]
  ])

  if pbStadiumHasWonCup("Tutorial") || $DEBUG

    titles.push("Start Up")
    descriptions.push("The best cup to attend to trainers who are still fairly new to the stadium.")
    stats.push([30,2])
    trainers.push([
      [:NURSERYAID, "Margaret", 0],
      [:TWINS, "Mia & Pia", 0],
      [:OFFICEWORKER, "Harold", 0],
      [:GUITARIST, "Randal", 0]
    ])

    # Phantom Cup (Persona 5)
    titles.push("Phantom")
    descriptions.push("Face off against rebellious thieves from another realm.")
    stats.push([40,2])
    trainers.push([
      [:LADY, "Haru", 0],
      [:SCHOOLGIRL, "Futaba", 0],
      [:CYCLIST_F, "Makoto", 0],
      [:PAINTER, "Yusuke", 0],
      [:LADY, "Ann", 0],
      [:YOUNGSTER, "Ryuji", 0],
      [:BURGLAR, "Morgana", 0],
      [:GAMBLER, "Ren", 0]
    ])

    # Aegis Cup (Xenoblade)
    titles.push("Aegis")
    descriptions.push("Battle a foreign party of unique opponents.")
    stats.push([40,3])
    trainers.push([
      [:ROUGHNECK, "Zeke", 0],
      [:VETERAN_F, "Morag", 0],
      [:ENGINEER, "Tora", 0],
      [:NURSE, "Nia", 0],
      [:MINER, "Rex", 0]
    ])

    if $DEBUG
      titles.push("May-Have-Been")
      descriptions.push("Sidelined trainers are here to battle! In another world, they may have had stories to tell.")
      stats.push([36,3])
      trainers.push([
        [:JANUS, "Janus", 0],
        [:OLDPROTAGONIST, "Indigo", 0]
      ])
    end

    titles.push("Echo")
    descriptions.push("This cup was sponsored by Pokémon Echoes, releasing within the next 30 years.")
    stats.push([40,3])
    trainers.push([
      [:LASS, "Amy", 0],
      [:ACETRAINER_M, "Kanai", 0],
      [:VETERAN_M, "Alcar", 0],
      [:PSYCHIC_M, "Arglos", 0]
    ])

    # Affinity Cup
    if pbStadiumHasWonCup("Start Up")
      titles.push("Affinity")
      descriptions.push("Test your strength against different opposing affinity boost tactics.")
      stats.push([40,4])
      trainers.push([
        [:SCIENTIST_M, "Ralph", 0],
        [:NURSE, "Holly", 0],
        [:ENGINEER, "Victor", 0],
        [:CRUSHGIRL, "Betty", 0]
      ])
    end

    if pbStadiumHasWonCup("Affinity")
      # No More Tutorial Cup
      titles.push("No More Tutorial")
      descriptions.push("The Tutorial Cup trainers are back for a long awaited rematch.")
      stats.push([50,5])
      trainers.push([
        [:ACETRAINER_M, "Ichi", 0],
        [:ACETRAINER_F, "Ni", 0],
        [:RICHBOY, "San", 0],
        [:VETERAN_M, "Yon", 0]
      ])

      # VGC Champions Cup
      titles.push("VGC Champions")
      descriptions.push("Battle against previous champions of competitive Pokemon battling.")
      stats.push([50,5])
      trainers.push([
        [:VETERAN_M, "Kazuyuki Tsuji", 0],
        [:VETERAN_M, "Ray Rizzo", 0],
        [:VETERAN_M, "Ray Rizzo", 1],
        [:VETERAN_M, "Arash Ommati", 0],
        [:VETERAN_M, "Sejun Park", 0],
        [:VETERAN_M, "Shoma Honami", 0],
        [:VETERAN_M, "Ryota Otsubo", 0],
        [:VETERAN_M, "Paul Ruiz", 0]
      ])
    end

    if pbStadiumHasWonCup(["VGC Champions", "No More Tutorial"])
      # Victory Cup
      titles.push("Victory")
      descriptions.push("The absolute strongest stadium trainers have gathered to pose a final ultimate challenge.")
      stats.push([70,6])
      trainers.push([
        [:SCIENTIST_F, "Sophie", 0],
        [:GENTLEMAN, "Louis", 0],
        [:CRUSHGIRL, "Ruby", 0],
        [:PARASOLLADY, "Sapphire", 0],
        [:PKMNRANGER_F, "Mirabel", 0],
        [:ACETRAINER_M, "Luigi", 0],
        [:PSYCHIC_M, "Pluto", 0],
        [:VETERAN_F, "Victoria", 0]
      ])
    end

  end

  #titles.push("Kanto Cup")
  #titles.push("Johto Cup")
  #titles.push("Hoenn Cup")
  #titles.push("Sinnoh Cup")
  #titles.push("Unova Cup")
  #titles.push("Kalos Cup")
  #titles.push("Alola Cup")

  idx = (0...titles.length).to_a
  idx.sort_by { |i| stats[i][0] }
  idx.sort_by { |i| trainers[i].length }
  idx.sort_by { |i| stats[i][1] }

  sorted_titles = []
  sorted_descriptions = []
  sorted_stats = []
  sorted_trainers = []

  idx.each do |i|
    sorted_titles.push(titles[i])
    sorted_descriptions.push(descriptions[i])
    sorted_stats.push(stats[i])
    sorted_trainers.push(trainers[i])
  end

  return [sorted_titles,sorted_descriptions,sorted_stats,sorted_trainers]

end