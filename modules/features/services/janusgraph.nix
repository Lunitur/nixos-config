{
  ...
}:
{
  flake.nixosModules.janusgraph =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # 1. Create the backend properties file (Berkeley DB)
      janusgraphProperties = pkgs.writeText "janusgraph-berkeley.properties" ''
        gremlin.graph=org.janusgraph.core.JanusGraphFactory
        storage.backend=berkeleyje
        # This path matches the StateDirectory we define in the systemd service
        storage.directory=/var/lib/janusgraph/data
      '';

      # 2. Create the server config, injecting the properties file from above
      gremlinServerConf = pkgs.writeText "gremlin-server.yaml" ''
        host: 127.0.0.1
        port: 8182
        channelizer: org.apache.tinkerpop.gremlin.server.channel.WebSocketChannelizer
        graphs: {
          # Nix will replace this variable with the exact /nix/store/... path
          graph: ${janusgraphProperties}
        }
        scriptEngines: {
          gremlin-groovy: {
            plugins: {
              org.janusgraph.graphdb.tinkerpop.plugin.JanusGraphGremlinPlugin: {},
              org.apache.tinkerpop.gremlin.server.jsr223.GremlinServerGremlinPlugin: {},
              org.apache.tinkerpop.gremlin.tinkergraph.jsr223.TinkerGraphGremlinPlugin: {},
              org.apache.tinkerpop.gremlin.jsr223.ImportGremlinPlugin: {
                classImports: [java.lang.Math],
                methodImports: [java.lang.Math#*]
              }
            }
          }
        }
        serializers:
          - { className: org.apache.tinkerpop.gremlin.util.ser.GraphBinaryMessageSerializerV1, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] } }
      '';

    in
    {
      environment.systemPackages = [ pkgs.janusgraph ];

      systemd.services.janusgraph = {
        description = "JanusGraph Gremlin Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          # Pass the generated /nix/store/ YAML file to the startup script
          ExecStart = "${pkgs.janusgraph}/bin/janusgraph-server ${gremlinServerConf}";

          DynamicUser = true;
          StateDirectory = "janusgraph";
          StateDirectoryMode = "0700";

          # Security best practices for systemd services
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          NoNewPrivileges = true;
          Restart = "on-failure";
        };
      };
    };
}
