# reference: https://www.consul.io/docs/agent

node_name = "consul"
server    = true
bootstrap = true

ui_config {
    enabled = true
}

datacenter = "dc1"
data_dir   = "CONSUL_DATA_DIR"
log_level  = "INFO"

addresses {
    http = "0.0.0.0"
}

connect {
    enabled = true
}
