# Plugin
class Neo4j::Session
  def self.embedded_db(db_location, config={})
      Neo4j::Embedded::EmbeddedSession.new(db_location, config)
  end
end


module Neo4j::Embedded
  class EmbeddedSession < Neo4j::Session

    class Error < StandardError
    end

    attr_reader :graph_db, :db_location
    extend Forwardable
    def_delegator :@graph_db, :begin_tx


    def initialize(db_location, config={})
      @db_location = db_location
      @auto_commit = !!config[:auto_commit]
      Neo4j::Session.register(self)
    end

    def start
      raise Error.new("Embedded Neo4j db is already running") if running?
      puts "Start embedded Neo4j db at #{db_location}"
      factory = Java::OrgNeo4jGraphdbFactory::GraphDatabaseFactory.new
      @graph_db = factory.newEmbeddedDatabase(db_location)
    end

    def factory_class
      Java::OrgNeo4jGraphdbFactory::GraphDatabaseFactory
      Java::OrgNeo4jTest::ImpermanentGraphDatabase
    end

    def close
      super
      shutdown
    end

    def shutdown
      graph_db && graph_db.shutdown
      @graph_db = nil
    end

    def running?
      !!graph_db
    end

    def query(*params, &query_dsl)
      begin
        result = super
        raise CypherError.new(result.error_msg, result.error_code, result.error_status) if result.respond_to?(:error?) && result.error?
        # TODO ugly, the server database must convert the result
        result.respond_to?(:to_hash_enumeration) ? result.to_hash_enumeration : result.to_a
      rescue Exception => e
        raise CypherError.new(e,nil,nil)
      end
    end

    # Performs a cypher query with given string.
    # Remember that you should close the resource iterator.
    # @param [String] q the cypher query as a String
    # @return (see #query)
    def _query(q, params={})
      engine = Java::OrgNeo4jCypherJavacompat::ExecutionEngine.new(@graph_db)
      result = engine.execute(q, Neo4j::Core::HashWithIndifferentAccess.new(params))
      Neo4j::Cypher::ResultWrapper.new(result)
    end

    def create_node(properties = nil, labels=[])
      if labels.empty?
        _java_node = graph_db.create_node
      else
        labels = EmbeddedLabel.as_java(labels)
        _java_node = graph_db.create_node(labels)
      end
# TODO
#      properties.each_pair { |k, v| _java_node[k]=v } if properties
      _java_node
    end
#    tx_methods :create_node

  end
end