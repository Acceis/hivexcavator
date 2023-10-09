# frozen_string_literal: true

# Internal
require 'hivexcavator/version'
# Third party
require 'hivex'
require 'paint'

class HivExcavator
  TYPE = {
    0 => 'none',
    1 => 'string',
    2 => 'expandstring',
    4 => 'dword', # hex
    11 => 'qword' # hex
  }.freeze

  PALETTE = {
    MAIN: '#fe218b', # 70d6ff
    SECOND: '#fed700', # ff70a6
    THIRD: '#21b0fe', # ff9770
    FOURTH: '#06d6a0' # ffd670
  }.freeze

  def initialize(hive)
    case hive
    when Hivex::Hivex
      @hive = hive
    when String
      @hive = Hivex.open(hive, {})
    end
  end

  # Does a node has children?
  def self.node_children?(hive, node)
    !hive.node_children(node).empty?
  end

  def node_children?(node)
    HivExcavator.node_children?(@hive, node)
  end

  # Does a node has a parent?
  def self.node_parent?(hive, node)
    hive.node_parent(node).integer?
  rescue Hivex::Error # Bad address
    false
  end

  def node_parent?(node)
    HivExcavator.node_parent?(@hive, node)
  end

  # Does a node has values?
  def self.node_values?(hive, node)
    !hive.node_values(node).empty?
  end

  def node_values?(node)
    HivExcavator.node_values?(@hive, node)
  end

  # Calculate the depth (nesting level) of a node (from the root node)
  def self.node_depth(hive, node)
    count = 0
    parent = node
    while node_parent?(hive, parent)
      parent = hive.node_parent(parent)
      count += 1
    end
    count
  end

  def node_depth(node)
    HivExcavator.node_depth(@hive, node)
  end

  # Output a number of whitespace depending on the depth
  def self.space_depth(hive, node, spaces = 2)
    ' ' * spaces * node_depth(hive, node)
  end

  def space_depth(node, spaces = 2)
    HivExcavator.space_depth(@hive, node, spaces)
  end

  # Try to resolve known types to extract the value else just fix encoding of the provided value
  def self.extract_value(hive, value)
    value_type = TYPE[hive.value_type(value)[:type]]
    case value_type
    when 'string'
      hive.value_string(value)
    when 'dword'
      hive.value_dword(value)
    when 'qword'
      hive.value_qword(value)
    else
      hive.value_value(value)[:value].encode('UTF-8', 'Windows-1252').gsub("\n", '')
    end
  end

  def extract_value(value)
    HivExcavator.extract_value(@hive, value)
  end

  # Display the BCD file as a tree
  # @example
  #   require 'hivexcavator'
  #   require 'hivex'
  #
  #   h = Hivex.open('/home/noraj/test/pxe/conf.bcd', {})
  #   root = h.root()
  #   puts "#{h.node_name(root)} (#{root})"
  #   HivExcavator.new(h).node_list(root)
  def self.node_list(hive, current_node)
    nodes = hive.node_children(current_node)
    nodes.each do |node|
      node_name = hive.node_name(node)
      puts "#{space_depth(hive, node)}#{Paint[node_name, PALETTE[:MAIN]]} (#{Paint[node, PALETTE[:SECOND]]})"
      if node_values?(hive, node)
        node_values = hive.node_values(node)
        node_values.each do |value|
          value_value = extract_value(hive, value)
          print "  #{space_depth(hive, node)}#{Paint[hive.value_key(value), PALETTE[:FOURTH]]} :"
          puts "#{Paint[value_value, PALETTE[:THIRD]]} (#{Paint[value, PALETTE[:SECOND]]})"
        end
      end
      node_list(hive, node) if node_children?(hive, node)
    end
  end

  def node_list(current_node)
    HivExcavator.node_list(@hive, current_node)
  end

  def self.diplay_store(hive)
    root = hive.root
    puts "#{Paint[hive.node_name(root), PALETTE[:MAIN]]} (#{Paint[root, PALETTE[:SECOND]]})"
  end

  def diplay_store
    HivExcavator.diplay_store(@hive)
  end

  def self.display_tree(hive)
    node_list(hive, hive.root)
  end

  def display_tree
    HivExcavator.display_tree(@hive)
  end

  # @example
  #   store = Hivex.open('/home/noraj/test/pxe/conf.bcd', {})
  #   HivExcavator.display(store)
  #   store.close
  def self.display(hive)
    diplay_store(hive)
    display_tree(hive)
  end

  # @example
  #   store = '/home/noraj/test/pxe/conf.bcd'
  #   hiex = HivExcavator.new(store)
  #   hiex.display
  def display
    HivExcavator.display(@hive)
  end
end
