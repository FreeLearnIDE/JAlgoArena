job "jalgoarena" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }

  migrate {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "elasticsearch-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "elasticsearch" {
      driver = "docker"

      config {
        image = "elasticsearch"
        network_mode = "host"
      }

      resources {
        cpu    = 750
        memory = 1000
      }

      service {
        name = "elastichsearch"
        tags = ["elk"]
        port = 9200
        address_mode = "driver"
        check {
          type      = "tcp"
          address_mode = "driver"
          interval  = "10s"
          timeout   = "1s"
        }
      }
    }
  }

  group "kibana-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "kibana" {
      driver = "docker"

      config {
        image = "kibana"
        network_mode = "host"
      }

      resources {
        cpu    = 750
        memory = 1000
      }

      service {
        name = "kibana"
        tags = ["elk"]
        port = 5601
        address_mode = "driver"
        check {
          type      = "tcp"
          address_mode = "driver"
          interval  = "10s"
          timeout   = "1s"
        }
      }
    }
  }

  group "logstash-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "logstash" {
      driver = "docker"

      config {
        image = "logstash"
        network_mode = "host"
        volumes = ["/home/jacek/jalgoarena/logstash:/config-dir"]
        args = [
          "-f", "/config-dir/logastash.conf"
        ]
      }

      resources {
        cpu    = 750
        memory = 1000
      }

      service {
        name = "logstash"
        tags = ["elk"]
        port = 4560
        address_mode = "driver"
        check {
          type      = "tcp"
          address_mode = "driver"
          interval  = "10s"
          timeout   = "1s"
        }
      }
    }
  }

  group "zk-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "zookeeper" {
      driver = "docker"

      config {
        image = "confluentinc/cp-zookeeper"
        network_mode = "host"
      }

      resources {
        cpu    = 750
        memory = 1000
      }

      env {
        ZOOKEEPER_CLIENT_PORT = 2181
      }

      service {
        name = "zookeeper"
        tags = ["zookeeper"]
        port = 2181
        address_mode = "driver"
        check {
          type      = "tcp"
          address_mode = "driver"
          interval  = "10s"
          timeout   = "1s"
        }
      }
    }
  }

  group "kafka-docker-1" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "kafka-1" {
      driver = "docker"

      config {
        image = "confluentinc/cp-kafka"
        network_mode = "host"
      }

      resources {
        cpu    = 1000
        memory = 1500
      }

      env {
        KAFKA_BROKER_ID = 0
        KAFKA_ADVERTISED_LISTENERS = "PLAINTEXT://localhost:9092"
        KAFKA_ZOOKEEPER_CONNECT = "localhost:2181"
      }

      service {
        name = "kafka1"
        tags = ["kafka"]
        port = 9092
        address_mode = "driver"
        check {
          type      = "tcp"
          address_mode = "driver"
          interval  = "10s"
          timeout   = "1s"
        }
      }
    }
  }

  group "kafka-docker-2" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "kafka-2" {
      driver = "docker"

      config {
        image = "confluentinc/cp-kafka"
        network_mode = "host"
      }

      resources {
        cpu    = 1000
        memory = 1500
      }

      env {
        KAFKA_BROKER_ID = 1
        KAFKA_ADVERTISED_LISTENERS = "PLAINTEXT://localhost:9093"
        KAFKA_ZOOKEEPER_CONNECT = "localhost:2181"
      }

      service {
        name = "kafka2"
        tags = ["kafka"]
        port = 9093
        address_mode = "driver"
        check {
          type      = "tcp"
          address_mode = "driver"
          interval  = "10s"
          timeout   = "1s"
        }
      }
    }
  }

  group "kafka-docker-3" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "kafka-3" {
      driver = "docker"

      config {
        image = "confluentinc/cp-kafka"
        network_mode = "host"
      }

      resources {
        cpu    = 1000
        memory = 1500
      }

      env {
        KAFKA_BROKER_ID = 2
        KAFKA_ADVERTISED_LISTENERS = "PLAINTEXT://localhost:9094"
        KAFKA_ZOOKEEPER_CONNECT = "localhost:2181"
      }

      service {
        name = "kafka3"
        tags = ["kafka"]
        port = 9094
        address_mode = "driver"
        check {
          type      = "tcp"
          address_mode = "driver"
          interval  = "10s"
          timeout   = "1s"
        }
      }
    }
  }

  group "traefik-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik"
        network_mode = "host"
        volumes = ["/home/jacek/jalgoarena/traefik.toml:/etc/traefik/traefik.toml"]
      }

      resources {
        cpu    = 750
        memory = 750
      }

      service {
        name = "traefik"
        tags = ["traefik"]
        address_mode = "driver"
        port = 5001
        check {
          type      = "tcp"
          address_mode = "driver"
          interval  = "10s"
          timeout   = "1s"
        }
      }
    }
  }

  group "auth-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "jalgoarena-auth" {
      driver = "docker"

      config {
        image = "spolnik/jalgoarena-auth:2.2.111"
        network_mode = "host"
        volumes = ["/home/jacek/jalgoarena/UserDetailsStore:/app/UserDetailsStore"]
      }

      resources {
        cpu    = 1000
        memory = 1500
      }
    }
  }

  group "events-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "jalgoarena-events" {
      driver = "docker"

      config {
        image = "spolnik/jalgoarena-events:2.2.20"
        network_mode = "host"
      }

      resources {
        cpu    = 1000
        memory = 1500
      }

      env {
        BOOTSTRAP_SERVERS = "localhost:9092,localhost:9093,localhost:9094"
      }
    }
  }

  group "judge-docker-1" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "jalgoarena-judge-1" {
      driver = "docker"

      config {
        image = "spolnik/jalgoarena-judge:2.2.445"
        network_mode = "host"
      }

      resources {
        cpu    = 1000
        memory = 1500
      }

      env {
        BOOTSTRAP_SERVERS = "localhost:9092,localhost:9093,localhost:9094"
      }
    }
  }

  group "judge-docker-2" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "jalgoarena-judge-2" {
      driver = "docker"

      config {
        image = "spolnik/jalgoarena-judge:2.2.445"
        network_mode = "host"
      }

      resources {
        cpu    = 1000
        memory = 1500
      }

      env {
        BOOTSTRAP_SERVERS = "localhost:9092,localhost:9093,localhost:9094"
        PORT = 6001
      }
    }
  }

  group "queue-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "jalgoarena-queue" {
      driver = "docker"

      config {
        image = "spolnik/jalgoarena-queue:2.2.28"
        network_mode = "host"
      }

      resources {
        cpu    = 1000
        memory = 1500
      }

      env {
        BOOTSTRAP_SERVERS = "localhost:9092,localhost:9093,localhost:9094"
      }
    }
  }

  group "ranking-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "jalgoarena-ranking" {
      driver = "docker"

      config {
        image = "spolnik/jalgoarena-ranking:2.2.38"
        network_mode = "host"
        volumes = ["/home/jacek/jalgoarena/RankingStore:/app/RankingStore"]
      }

      resources {
        cpu    = 1000
        memory = 1500
      }

      env {
        BOOTSTRAP_SERVERS = "localhost:9092,localhost:9093,localhost:9094"
      }
    }
  }

  group "submissions-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "jalgoarena-submissions" {
      driver = "docker"

      config {
        image = "spolnik/jalgoarena-submissions:2.2.152"
        network_mode = "host"
        volumes = ["/home/jacek/jalgoarena/SubmissionsStore:/app/SubmissionsStore"]
      }

      resources {
        cpu    = 1000
        memory = 1500
      }

      env {
        BOOTSTRAP_SERVERS = "localhost:9092,localhost:9093,localhost:9094"
      }
    }
  }

  group "ui-docker" {
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 1000
    }

    task "jalgoarena-ui" {
      driver = "docker"

      config {
        image = "spolnik/jalgoarena-ui:2.2.4"
        network_mode = "host"
      }

      resources {
        cpu    = 750
        memory = 750
      }
    }
  }
}