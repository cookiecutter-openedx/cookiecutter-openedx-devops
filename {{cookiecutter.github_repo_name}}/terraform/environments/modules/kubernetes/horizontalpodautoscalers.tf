resource "kubernetes_horizontal_pod_autoscaler_v2" "cms-worker" {
  metadata {
    name      = "cms-worker"
    namespace = var.environment_namespace
  }

  spec {
    min_replicas = 1
    max_replicas = 2

    scale_target_ref {
      kind = "Deployment"
      name = "cms-worker"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type          = "AverageValue"
          average_value = "50m"
        }
      }
    }

    behavior {
      scale_down {
        select_policy                = "Max"
        stabilization_window_seconds = 300
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 20
          period_seconds = 300
        }
      }
      scale_up {
        select_policy                = "Max"
        stabilization_window_seconds = 0
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 300
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "cms" {
  metadata {
    name      = "cms"
    namespace = var.environment_namespace
  }

  spec {
    min_replicas = 2
    max_replicas = 2

    scale_target_ref {
      kind = "Deployment"
      name = "cms"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type          = "AverageValue"
          average_value = "50m"
        }
      }
    }

    behavior {
      scale_down {
        select_policy                = "Max"
        stabilization_window_seconds = 300
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 20
          period_seconds = 300
        }
      }
      scale_up {
        select_policy                = "Max"
        stabilization_window_seconds = 0
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 300
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "discovery" {
  metadata {
    name      = "discovery"
    namespace = var.environment_namespace
  }

  spec {
    min_replicas = 1
    max_replicas = 1

    scale_target_ref {
      kind = "Deployment"
      name = "discovery"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type          = "AverageValue"
          average_value = "50m"
        }
      }
    }

    behavior {
      scale_down {
        select_policy                = "Max"
        stabilization_window_seconds = 300
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 20
          period_seconds = 300
        }
      }
      scale_up {
        select_policy                = "Max"
        stabilization_window_seconds = 0
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 300
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "lms-worker" {
  metadata {
    name      = "lms-worker"
    namespace = var.environment_namespace
  }

  spec {
    min_replicas = 1
    max_replicas = 2

    scale_target_ref {
      kind = "Deployment"
      name = "lms-worker"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type          = "AverageValue"
          average_value = "50m"
        }
      }
    }

    behavior {
      scale_down {
        select_policy                = "Max"
        stabilization_window_seconds = 300
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 20
          period_seconds = 300
        }
      }
      scale_up {
        select_policy                = "Max"
        stabilization_window_seconds = 0
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 300
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "lms" {
  metadata {
    name      = "lms"
    namespace = var.environment_namespace
  }

  spec {
    min_replicas = 2
    max_replicas = 2

    scale_target_ref {
      kind = "Deployment"
      name = "lms"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type          = "AverageValue"
          average_value = "50m"
        }
      }
    }

    behavior {
      scale_down {
        select_policy                = "Max"
        stabilization_window_seconds = 300
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 20
          period_seconds = 300
        }
      }
      scale_up {
        select_policy                = "Max"
        stabilization_window_seconds = 0
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 300
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "mfe" {
  metadata {
    name      = "mfe"
    namespace = var.environment_namespace
  }

  spec {
    min_replicas = 1
    max_replicas = 1

    scale_target_ref {
      kind = "Deployment"
      name = "mfe"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type          = "AverageValue"
          average_value = "50m"
        }
      }
    }

    behavior {
      scale_down {
        select_policy                = "Max"
        stabilization_window_seconds = 300
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 20
          period_seconds = 300
        }
      }
      scale_up {
        select_policy                = "Max"
        stabilization_window_seconds = 0
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 300
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "notes" {
  metadata {
    name      = "notes"
    namespace = var.environment_namespace
  }

  spec {
    min_replicas = 1
    max_replicas = 1

    scale_target_ref {
      kind = "Deployment"
      name = "notes"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type          = "AverageValue"
          average_value = "50m"
        }
      }
    }

    behavior {
      scale_down {
        select_policy                = "Max"
        stabilization_window_seconds = 300
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 20
          period_seconds = 300
        }
      }
      scale_up {
        select_policy                = "Max"
        stabilization_window_seconds = 0
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 300
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "smtp" {
  metadata {
    name      = "smtp"
    namespace = var.environment_namespace
  }

  spec {
    min_replicas = 1
    max_replicas = 1

    scale_target_ref {
      kind = "Deployment"
      name = "smtp"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type          = "AverageValue"
          average_value = "50m"
        }
      }
    }

    behavior {
      scale_down {
        select_policy                = "Max"
        stabilization_window_seconds = 300
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 20
          period_seconds = 300
        }
      }
      scale_up {
        select_policy                = "Max"
        stabilization_window_seconds = 0
        policy {
          type           = "Pods"
          value          = 5
          period_seconds = 300
        }
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 300
        }
      }
    }
  }
}
