require 'forwardable'
require 'fileutils'

require 'neo4j-cypher'

require 'neo4j-core/helpers'
require 'neo4j-core/property'
require 'neo4j/exceptions'

require 'neo4j-core/hash_with_indifferent_access'
require 'neo4j/property_container'
require 'neo4j/entity_equality'
require 'neo4j/node'
require 'neo4j/label'
require 'neo4j/session'

require 'neo4j/relationship'
require 'neo4j/transaction'

require 'neo4j-server'

if RUBY_PLATFORM == 'java'
  require 'neo4j-embedded'
else
  # just for the tests
  module Neo4j::Embedded
  end
end


#require 'neo4j-wrapper' # TODO should be move to a separate gem
