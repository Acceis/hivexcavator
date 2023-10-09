# frozen_string_literal: true

# Third party
require 'docopt'
require 'paint'

class HivExcavator
  # module used for the CLI binary only, not required by the library
  module CLI
    pal = HivExcavator::PALETTE

    doc = <<~DOCOPT
      #{Paint['HivExcavator', :bold, pal[:MAIN]]} version #{Paint[HivExcavator::VERSION, :bold, pal[:THIRD]]}

      #{Paint['Usage:', pal[:SECOND]]}
        #{Paint['hivexcavator', pal[:THIRD]]} [options] <bcd>

      #{Paint['Parameters:', pal[:SECOND]]}
        #{Paint['<bcd>', pal[:FOURTH]]}           BCD file

      #{Paint['Options:', pal[:SECOND]]}
        #{Paint['--no-color', pal[:FOURTH]]}      Disable colorized output (NO_COLOR environment variable is respected too)
        #{Paint['--debug', pal[:FOURTH]]}         Display arguments
        #{Paint['-h', pal[:FOURTH]]}, #{Paint['--help', pal[:FOURTH]]}      Show this screen
        #{Paint['--version', pal[:FOURTH]]}       Show version

      #{Paint['Examples:', pal[:SECOND]]}
        hivexcavator ~/test/pxe/conf.bcd

      #{Paint['Project:', pal[:SECOND]]}
        #{Paint['author', :underline]} (https://pwn.by/noraj / https://twitter.com/noraj_rawsec)
        #{Paint['source', :underline]} (https://github.com/acceis/hivexcavator)
        #{Paint['documentation', :underline]} (https://acceis.github.io/hivexcavator)
    DOCOPT

    begin
      args = Docopt.docopt(doc, version: HivExcavator::VERSION)
      Paint.mode = 0 if args['--no-color']
      puts args if args['--debug']
      if args['<bcd>']
        hiex = HivExcavator.new(args['<bcd>'])
        hiex.display
      end
    rescue Docopt::Exit => e
      puts e.message
    end
  end
end
