resource "aws_vpc" "personal-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Personal-VPC"
  }
}

resource "aws_subnet" "public-subnet-1" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = "${aws_vpc.personal-vpc.id}"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Public-Subnet-1"
  }
}

resource "aws_internet_gateway" "production-igw" {
  vpc_id = "${aws_vpc.personal-vpc.id}"

  tags = {
    Name = "Personal-IGW"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = "${aws_vpc.personal-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.production-igw.id}"
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public-subnet-1-association" {
  route_table_id = "${aws_route_table.public-route-table.id}"
  subnet_id      = "${aws_subnet.public-subnet-1.id}"
}

resource "aws_route" "public-internet-gw-route" {
  route_table_id         = "${aws_route_table.public-route-table.id}"
  gateway_id             = "${aws_internet_gateway.production-igw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "ec2_public_security_group" {
  name = "EC2-Public-SG"
  description = "Internet reaching access for EC2 Instances"
  vpc_id = "${aws_vpc.personal-vpc.id}"

  ingress {
    from_port = 80
    protocol = "TCP"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "TCP"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "rutracker_notifier_bot_setup_script" {
  template = "${file("templates/setup_rutracker_notifier_bot.tpl")}"
  vars = {
    token                   = "${var.rutracker_notifier_bot_token}"
    mongo_connection_string = "${var.mongo_connection_string}" 
  }
}

data "template_file" "transmission_management_bot_setup_script" {
  template = "${file("templates/setup_transmission_management_bot.tpl")}"
  vars = {
    token                     = "${var.transmission_management_bot_token}"
    transmission_host         = "${var.transmission_host}"
    transmission_port         = "${var.transmission_port}"
    transmission_user         = "${var.transmission_user}"
    transmission_password     = "${var.transmission_password}"
    transmission_download_dir = "${var.transmission_download_dir}"
  }
}

data "template_file" "shared_budget_bot_setup_script" {
  template = "${file("templates/setup_shared_budget_bot.tpl")}"
  vars = {
    token            = "${var.shared_budget_bot_token}"
    person_1_tg_id   = "${var.person_1_tg_id}"
    person_2_tg_id   = "${var.person_2_tg_id}"
    scope            = "${var.scope}"
    spreadsheet_id   = "${var.spreadsheet_id}"
    sheet_id         = "${var.sheet_id}"
    pickle_gdrive_id = "${var.budget_pickle_gdrive_id}"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCGuEH5ecemOkUQCUTayfuBlFQn+kDUbZ9WA/qBag3mRY1rIxpUnSl02hfJ+nZiMJJXyHmIpsM177KMasX2lDiLMzbzVv8jhqpeFf5udGbfZsh5PsCMRbvIFHgSlKYbg0sMR+7KpXkv+a0FUeAOm6NarUbYJpBEJ0FAm5D+tvf8NXgs2k4ovZborslbttzw8S7EyiWkSm7LSfYYe5hVHbqbPDeG4dIOFEaXC5HRMJPdW2gQzaBxPjf967STH5caAS54ljoyRUM13dCd7CN/hZlzphPjp9gBIegsDVlmsY7HE1MV7bvCd+JzY3+lRS3nO65OYqv2pf196aJajIRIIKCt"
}

resource "aws_instance" "python" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.nano"
  key_name                    = "${aws_key_pair.ssh_key.key_name}"
  subnet_id                   = "${aws_subnet.public-subnet-1.id}"
  security_groups             = ["${aws_security_group.ec2_public_security_group.id}"]
  associate_public_ip_address = true
  source_dest_check           = false

  provisioner "file" {
    destination = "/home/ubuntu/setup_1.sh"
    content     = "${data.template_file.rutracker_notifier_bot_setup_script.rendered}"
  }

  provisioner "file" {
    destination = "/home/ubuntu/setup_2.sh"
    content     = "${data.template_file.transmission_management_bot_setup_script.rendered}"
  }

  provisioner "file" {
    destination = "/home/ubuntu/setup_3.sh"
    content     = "${data.template_file.shared_budget_bot_setup_script.rendered}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh",
      "sudo usermod -aG docker ubuntu",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /home/ubuntu/setup_1.sh CI",
      "sudo sh /home/ubuntu/setup_2.sh",
      "sudo sh /home/ubuntu/setup_3.sh"
    ]
  }

  connection {
    host        = "${aws_instance.python.public_ip}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${var.personal_key_pem}"
  }
}
