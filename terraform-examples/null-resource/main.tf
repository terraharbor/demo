resource "null_resource" "hello_world" {
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'Hello, World!'"
  }
}

resource "null_resource" "recreated_with_timestamp" {
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'Recreated null resource with timestamp: ${self.triggers.timestamp}'"
  }
}

resource "null_resource" "static" {
  provisioner "local-exec" {
    command = "echo 'Static null resource that echoes only on creation.'"
  }
}
