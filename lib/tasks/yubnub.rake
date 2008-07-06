namespace :yubnub do
  
  desc "Import Latest Commands from YubNub.com"
  task :import_latest => :environment do
    # TODO
  end
  
  desc "Import Most Used Commands from YubNub.com"
  task :import_most_used => :environment do
    # http://yubnub.org/kernel/most_used_commands
  end

  desc "Import Golden Egg Commands from YubNub.com"
  task :import_eggs => :environment do
    require 'feedtools'
    # http://yubnub.org/all_golden_eggs.xml

    feed = FeedTools.Feed.open("http://yubnub.org/all_golden_eggs.xml")
    feed.items.each do |item|
      
    end
  end
  
  
end