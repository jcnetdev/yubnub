# GOOGLE SEARCH
Command.seed(:name) do |s|
  s.name = "g"
  s.url = "http://www.google.com/search?q=%s"
  s.description = \
"SYNOPSIS
        g [keywords]

EXAMPLE
        g YubNub

DESCRIPTION
        Performs a Google search using the given keywords."

  s.golden_egg_date = DateTime.now

end

# KERNEL - MAN
Command.seed(:name) do |s|
  s.name = "man"
  s.url = "/kernel/man?args=%s"
  s.description = \
"SYNOPSIS
        man command-name

EXAMPLE
        man gim

DESCRIPTION
        Displays helpful information about the given command.
        \"man\" stands for \"manual\". 

        You're looking at man information right now!

"
  s.golden_egg_date = DateTime.now
end

# CREATE ACTION SHORTCUT
Command.seed(:name) do |s|
  s.name = "create"
  s.url = "/commands/new?name=%s"
  s.description = \
"SYNOPSIS
        create [command-name]

EXAMPLE
        create

DESCRIPTION
        Creates a new YubNub command with the given name (must not
        already exist). You will be prompted for a URL pointing to
        the implementation of the command -- it might be an existing
        service (e.g. the Google Image Search submit form), or your
        own custom implementation sitting on your own server.

        Welcome to the Web OS: small pieces, loosely joined.
"
  s.golden_egg_date = DateTime.now
end

# KERNEL - LS
Command.seed(:name) do |s|
  s.name = "ls"
  s.url = "/kernel/ls?args=%s"
  s.description = \
"SYNOPSIS
        ls [word or phrase]

EXAMPLES
        ls
        ls music

DESCRIPTION
        Lists information about all the commands in YubNub. Sorts entries
        by date.

        If you specify a word or phrase, YubNub will search the 
        descriptions, names, and urls for that word or phrase.
        For example, \"ls music\" will return all YubNub commands pertaining 
        to music.
"
  s.golden_egg_date = DateTime.now
end

# KERNEL - GE
Command.seed(:name) do |s|
  s.name = "ge"
  s.url = "/kernel/golden_eggs?args=%s"
  s.description = \
"SYNOPSIS
        ge [word or phrase]

EXAMPLES
        ge
        ge dictionary

DESCRIPTION
        Displays the YubNub Golden Eggs - a list of YubNub commands
        that people seem to find particularly useful and interesting.

        If you specify a word or phrase, YubNub will search the 
        descriptions, names, and urls for that word or phrase.
        For example, \"ge dictionary\" will return all Golden-Egg commands 
        pertaining to dictionaries.

"
  s.golden_egg_date = DateTime.now
end