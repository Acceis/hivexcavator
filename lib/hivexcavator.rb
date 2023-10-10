# frozen_string_literal: true

# Internal
require 'hivexcavator/version'
# Third party
require 'hivex'
require 'paint'

# Extracting the contents of Microsoft Windows Registry (hive) and display it as a colorful tree but mainly focused on
# parsing BCD files to extract WIM files path for PXE attacks.
class HivExcavator
  # Windows Registry Value Type
  # @see https://learn.microsoft.com/en-us/dotnet/api/microsoft.win32.registryvaluekind?view=net-7.0
  TYPE = {
    -1 => 'none',
    0 => 'unknown',
    1 => 'string',
    2 => 'expandstring',
    3 => 'binary',
    4 => 'dword', # hex
    7 => 'multistring',
    11 => 'qword' # hex
  }.freeze

  # Color palette of HivExcavator for display
  PALETTE = {
    MAIN: '#fe218b', # 70d6ff
    SECOND: '#fed700', # ff70a6
    THIRD: '#21b0fe', # ff9770
    FOURTH: '#06d6a0' # ffd670
  }.freeze

  # Instantiate HivExcavator
  # @param hive [String|Hivex::Hivex] Can be either a file path to a BCD file +String+ or a Hivex (hive)
  #   instance +Hivex::Hivex+.
  def initialize(hive)
    case hive
    when Hivex::Hivex
      @hive = hive
    when String
      @hive = Hivex.open(hive, {})
    end
  end

  # Does a node has children?
  # @param hive [Hivex::Hivex] hive instance
  # @param node [Integer] node index
  # @return [Boolean]
  def self.node_children?(hive, node)
    !hive.node_children(node).empty?
  end

  # Does a node has children?
  # @param node [Integer] node index
  # @return [Boolean]
  def node_children?(node)
    HivExcavator.node_children?(@hive, node)
  end

  # Does a node has a parent?
  # @param hive [Hivex::Hivex] hive instance
  # @param node [Integer] node index
  # @return [Boolean]
  def self.node_parent?(hive, node)
    hive.node_parent(node).integer?
  rescue Hivex::Error # Bad address
    false
  end

  # Does a node has a parent?
  # @param node [Integer] node index
  # @return [Boolean]
  def node_parent?(node)
    HivExcavator.node_parent?(@hive, node)
  end

  # Does a node has values?
  # @param hive [Hivex::Hivex] hive instance
  # @param node [Integer] node index
  # @return [Boolean]
  def self.node_values?(hive, node)
    !hive.node_values(node).empty?
  end

  # Does a node has values?
  # @param node [Integer] node index
  # @return [Boolean]
  def node_values?(node)
    HivExcavator.node_values?(@hive, node)
  end

  # Calculate the depth (nesting level) of a node (from the root node)
  # @param hive [Hivex::Hivex] hive instance
  # @param node [Integer] node index
  # @return [Integer] depth level
  def self.node_depth(hive, node)
    count = 0
    parent = node
    while node_parent?(hive, parent)
      parent = hive.node_parent(parent)
      count += 1
    end
    count
  end

  # Calculate the depth (nesting level) of a node (from the root node)
  # @param node [Integer] node index
  # @return [Integer] depth level
  def node_depth(node)
    HivExcavator.node_depth(@hive, node)
  end

  # Output a number of whitespace depending on the depth
  # @param hive [Hivex::Hivex] hive instance
  # @param node [Integer] node index
  # @param spaces [Integer] number of whitespaces per level
  # @return [String] whitespaces
  def self.space_depth(hive, node, spaces = 2)
    ' ' * spaces * node_depth(hive, node)
  end

  # Output a number of whitespace depending on the depth
  # @param node [Integer] node index
  # @param spaces [Integer] number of whitespaces per level
  # @return [String] whitespaces
  def space_depth(node, spaces = 2)
    HivExcavator.space_depth(@hive, node, spaces)
  end

  # Try to resolve known types to extract the value else just fix encoding of the provided value
  # @param hive [Hivex::Hivex] hive instance
  # @param value [Integer] value index
  # @return [String] The decoded value
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

  # Try to resolve known types to extract the value else just fix encoding of the provided value
  # @param value [Integer] value index
  # @return [String] The decoded value
  def extract_value(value)
    HivExcavator.extract_value(@hive, value)
  end

  # Display the BCD file as a tree
  # @param hive [Hivex::Hivex] hive instance
  # @param current_node [Integer] node index
  # @return [nil]
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
    nil
  end

  # Display the BCD file as a tree
  # @param current_node [Integer] node index
  # @return [nil]
  def node_list(current_node)
    HivExcavator.node_list(@hive, current_node)
  end

  # Display a line with the name of the store / hive
  # @param hive [Hivex::Hivex] hive instance
  # @return [nil]
  def self.diplay_store(hive)
    root = hive.root
    puts "#{Paint[hive.node_name(root), PALETTE[:MAIN]]} (#{Paint[root, PALETTE[:SECOND]]})"
  end

  # Display a line with the name of the store / hive
  # @return [nil]
  def diplay_store
    HivExcavator.diplay_store(@hive)
  end

  # Display the tree of all nodes, key and values
  # @param hive [Hivex::Hivex] hive instance
  # @return [nil]
  def self.display_tree(hive)
    node_list(hive, hive.root)
  end

  # Display the tree of all nodes, key and values
  # @return [nil]
  def display_tree
    HivExcavator.display_tree(@hive)
  end

  # Display the store name ({diplay_store}) and the tree ({display_tree})
  # @param hive [Hivex::Hivex] hive instance
  # @return [nil]
  # @example
  #   require 'hivexcavator'
  #   require 'hivex'
  #
  #   store = Hivex.open('/home/noraj/test/pxe/conf.bcd', {})
  #   HivExcavator.display(store)
  #   store.close
  def self.display(hive)
    diplay_store(hive)
    display_tree(hive)
  end

  # Display the store name ({diplay_store}) and the tree ({display_tree})
  # @return [nil]
  # @example
  #   require 'hivexcavator'
  #   require 'hivex'
  #
  #   store = '/home/noraj/test/pxe/conf.bcd'
  #   hiex = HivExcavator.new(store)
  #   hiex.display
  def display
    HivExcavator.display(@hive)
  end
end
