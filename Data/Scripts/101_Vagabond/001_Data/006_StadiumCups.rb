def pbStadiumCups

  titles = []
  descriptions = []
  stats = [] # [max_level, max_pkmn, difficulty]
  trainers = [] # [type, name, party, win, *before, *after]
  doubles = []

  titles.push("Tutorial Cup")
  descriptions.push("Get used to the Stadium battles with this Tutorial Cup.")
  stats.push([20,2,1])
  trainers.push([
    [:YOUNGSTER, "Ichi", 0,
      "You beat me...",
      "First time here?WT Good luck beating me!",
      "Good luck, pal.WT You're strong!"],
    [:LASS, "Ni", 0,
      "Nice work!",
      "I'm the second one up!WT Are you pumped?",
      "I'm sure you'll win the next battle!"],
    [:PRESCHOOLER_M, "San", 0,
      "I've been whomped...",
      "I've come to WHOMP you!"],
    [:SCHOOLBOY, "Yon", 0,
      "Looks like you're ready to go!",
      "Getting used to the stadium?WT I'm your final match this Cup!",
      "This was just the tutorial Cup.WT Just wait until you get to the really tough matches!"]
  ])
  doubles.push(true)

  if pbStadiumHasWonCup("Tutorial Cup") || $DEBUG

    titles.push("Double Trouble Cup")
    descriptions.push("Go head to head against trainers in double battles.")
    stats.push([30,4,2])
    trainers.push([
      [:NURSERYAID, "Margaret", 0,
        "You're not just a kid...",
        "I can handle an entire kindergarten. Two Pokémon at once should be easy!"],
      [:TWINS, "Mia & Pia", 0,
        "We need to work on our twin synergy.",
        "Twogether we are stronger than anyone!"],
      [:OFFICEWORKER, "Harold", 0,
        "I need a break...",
        "I work two jobs, and this is not one of them!"],
      [:GUITARIST, "Randal", 0,
        "Want to do another Round?",
        "Go my Pokemon! Work together and create the perfect symphony!"]
    ])
    doubles.push(true)

    titles.push("May-Have-Been Cup")
    descriptions.push("Sidelined trainers are here to battle! In another world, they may have had stories to tell.")
    stats.push([36,4,3])
    trainers.push([
      [:JANUS, "Janus", 0,
        "Have we met?WT You remind me of the friend I made when I started my journey!",
        "You sure hit hard.WT You would definitely be strong where I came from."],
      [:OLDPROTAGONIST, "Indigo", 0,
        "I see you have company with you.WT You've made friends with both Amethyst and Kira.WT They are both alike and different from the ones I knew.",
        "I'm glad to see you are taking good care of my friends in my stead."]
    ])
    doubles.push(true)

    # Affinity Cup
    titles.push("Affinity Cup")
    descriptions.push("Test your strength against opposing affinity boosts.")
    stats.push([40,4,4])
    trainers.push([
      [:SCIENTIST_M, "Ralph", 0, "..."],
      [:NURSE, "Holly", 0, "..."],
      [:ENGINEER, "Victor", 0, "..."],
      [:CRUSHGIRL, "Betty", 0, "..."]
    ])
    doubles.push(true)

    # Phantom Cup (Persona 5)
    titles.push("Phantom Cup")
    descriptions.push("Face off against rebellious thieves from another realm.")
    stats.push([40,2,3])
    trainers.push([
      [:LADY, "Haru", 0, "..."],
      [:SCHOOLGIRL, "Futaba", 0, "..."],
      [:CYCLIST_F, "Makoto", 0, "..."],
      [:PAINTER, "Yusuke", 0, "..."],
      [:LADY, "Ann", 0, "..."],
      [:YOUNGSTER, "Ryuji", 0, "..."],
      [:BURGLAR, "Morgana", 0, "..."],
      [:GAMBLER, "Ren", 0, "..."]
    ])
    doubles.push(true)

    # Aegis Cup (Xenoblade)
    titles.push("Aegis Cup")
    descriptions.push("Battle a foreign party of unique opponents.")
    stats.push([50,3,4])
    trainers.push([
      [:ROUGHNECK, "Zeke", 0, "..."],
      [:VETERAN_F, "Morag", 0, "..."],
      [:ENGINEER, "Tora", 0, "..."],
      [:NURSE, "Nia", 0, "..."],
      [:MINER, "Rex", 0, "..."]
    ])
    doubles.push(true)

    # VGC Champions Cup
    titles.push("VGC Champions Cup")
    descriptions.push("Battle against previous champions of competitive Pokemon battling.")
    stats.push([50,6,5])
    trainers.push([
      [:VETERAN_M, "Kazuyuki Tsuji", 0,
        "..."],
      [:VETERAN_M, "Ray Rizzo", 0,
        "..."],
      [:VETERAN_M, "Ray Rizzo", 1,
        "..."],
      [:VETERAN_M, "Arash Ommati", 0,
        "..."],
      [:VETERAN_M, "Sejun Park", 0,
        "..."],
      [:VETERAN_M, "Shoma Honami", 0,
        "..."],
      [:VETERAN_M, "Ryota Otsubo", 0,
        "..."],
      [:VETERAN_M, "Paul Ruiz", 0,
        "..."]
    ])
    doubles.push(true)

    # No More Tutorial Cup
    titles.push("No More Tutorial")
    descriptions.push("The Tutorial Cup trainers are back for a long awaited rematch.")
    stats.push([50,3,5])
    trainers.push([
      [:ACETRAINER_M, "Ichi", 0,
        "You beat me again...",
        "This has been a long time coming, hasn't it?",
        "You've really been keeping up all this time!"],
      [:ACETRAINER_F, "Ni", 0,
        "Impressive!",
        "Wow, we've both come really far, haven't we?",
        "You'll probably ace the other trainers here!"],
      [:RICHBOY, "San", 0,
        "Yet again...",
        "Last time I got whomped, but this time shall be different!"],
      [:VETERAN_M, "Yon", 0,
        "I can't surpass you...",
        "I will go all out this time, for a rematch!",
        "You've come so far since the Tutorial Cup.WT This was a fun battle. "]
    ])
    doubles.push(true)

  end

  #titles.push("Kanto Cup")
  #titles.push("Johto Cup")
  #titles.push("Hoenn Cup")
  #titles.push("Sinnoh Cup")
  #titles.push("Unova Cup")
  #titles.push("Kalos Cup")
  #titles.push("Alola Cup")

  return [titles,descriptions,stats,trainers,doubles]

end