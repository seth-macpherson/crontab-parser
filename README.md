# Crontab::Parser

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'crontab-parser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crontab-parser

## Usage

    cron = CrontabParser.new(`crontab -l`)
    now = Time.now
    cron.find_all{|row|
      row.should_run?(now)
    }.each{|row|
      puts "#{row.cmd} goes run just now"
    }

    cron = CrontabParser.new(<<-CRON)
    * * * * * monitor-process
    @daily mailme
    @monthly full-backup
    CRON

    now = Time.now
    cron.find_all{|row|
      row.should_run?(now)
    }.each{|row|
      puts "#{row.cmd} goes run just now"
    }


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
