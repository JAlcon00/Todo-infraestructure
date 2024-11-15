provider "digitalocean" {
  token = var.DO_TOKEN
}

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  backend "s3" {
      endpoints = {
        s3 = "https://sfo3.digitaloceanspaces.com"
      }
      bucket = "devjesus"
      key = "terraform.tfstate"
      skip_region_validation      = true
      skip_credentials_validation = true
      skip_metadata_api_check     = true
      skip_requesting_account_id  = true
      skip_s3_checksum            = true
      region = "us-east-1"
  }
}


//xd
resource "digitalocean_project" "jesus_server_proyect" {
  name        = "jesus_server_web"
  description = "Jalcon Server Proyect"
  resources   = [digitalocean_droplet.jesus_server_droplet.urn]

}

resource "digitalocean_ssh_key" "jesus_server_ssh_key" {
  name       = "jesus_server_web_prod"
  public_key = file("./keys/jesus_server.pub")
}

resource "digitalocean_droplet" "jesus_server_droplet" {
  name      = "jesusserver"
  size      = "s-2vcpu-4gb-120gb-intel"
  image     = "ubuntu-20-04-x64"
  region    = "sfo3"
  ssh_keys  = [digitalocean_ssh_key.jesus_server_ssh_key.id]
  user_data = file("./docker-install.sh")

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /projects",
      "touch /projects/.env",
      "echo \"MYSQL_DATABASE=${var.MYSQL_DATABASE}\" >> /projects/.env",
      "echo \"MYSQL_USER=${var.MYSQL_USER}\" >> /projects/.env",
      "echo \"MYSQL_HOST=${var.MYSQL_HOST}\" >> /projects/.env",
      "echo \"MYSQL_ROOT_PASSWORD=${var.MYSQL_ROOT_PASSWORD}\" >> /projects/.env"
    ]

  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("./keys/jesus_server")
    host        = self.ipv4_address
  }

  provisioner "file" {
    source      = "./containers/docker-compose.yml"
    destination = "/projects/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("./keys/jesus_server")
      host        = self.ipv4_address
    }
  }
}

# resource "time_sleep" "wait_docker_install" {
#   depends_on      = [digitalocean_droplet.jesus_server_droplet]
#   create_duration = "130s"



# }


# resource "null_resource" "init_api" {
#   depends_on = [ time_sleep.wait_docker_install] 
#   provisioner "remote-exec" {
#     inline = [ 
#       "cd /projects",
#       "docker-compose up -d"
#      ]
#     connection {
#       type        = "ssh"
#       user        = "root"
#       private_key = file("./keys/jesus_server")
#       host        = digitalocean_droplet.jesus_server_droplet.ipv4_address
#     }
  
    
#   }
  
# }

/*

resource "null_resource" "init_nginx" {
  depends_on = [time_sleep.wait_docker_install]
  connection {
    type        = "ssh"
    host        = digitalocean_droplet.jesus_server_droplet.ipv4_address
    user        = "root"
    private_key = file("./keys/jesus_server")
  }
  provisioner "remote-exec" {
    inline = ["docker container run --name=Adidas -dp 80:80 nginx"]
  }


}

resource "null_resource" "adidas_copy_folder" {
  provisioner "file" {
    source      = "./adidas"
    destination = "/adidas"
  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("./keys/jesus_server")
    host        = digitalocean_droplet.jesus_server_droplet.ipv4_address
  }
}
resource "null_resource" "copy_to_nginx_container" {
  depends_on = [null_resource.adidas_copy_folder, null_resource.init_nginx]
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("./keys/jesus_server")
    host        = digitalocean_droplet.jesus_server_droplet.ipv4_address

  }
  provisioner "remote-exec" {
    inline = ["docker cp /adidas/. Adidas:/usr/share/nginx/html"]
  }
} 
*/
output "ip" {
  value = digitalocean_droplet.jesus_server_droplet.ipv4_address

}
# 1. Hacer cd /
# 2. docker cp adidas/. Adidas:/usr/share/nginx/html
