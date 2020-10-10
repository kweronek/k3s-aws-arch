# This file is a template file
# please replace placeholders by valid keys/key par name respectively
# thereafter please remove the subsequent comment signs /* and */
/*
variable "access_key" {
  default = "ASDFTGSSGSAFG4FGSFDSS"
}

variable "secret_key" {
  default = "ASDfasdFAsda*AfafdfddadfasddEbJZSEDSf$"
}

variable "ami_key_pair_name" {
  default = "Terraform-kp"
}
*/
#---------------#
#  provider.tf  #
#---------------#

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.aws_region
}
#----------------#
#  variables.tf  #
#----------------#

variable "aws_region" { 
   default = "us-east-1" # North Virginia
#  default = "us-east-2" # Ohio
}

variable "vpc_name" { default = "cloud0" }
variable "stage" { default = "archdev" }
variable "env" { default = "dev" }

variable "ami_name" { 
#  default = "Amazon Linux 2"
   default = "Ubuntu 20.04 LTS"
#  default = "Ubuntu 18.04 LTS"
#  default = "openSUSE 15.2"
#  default = "SLES 15.2"
#  default = "K3OS-v0.11.0 KW"
}

variable "instance_type" {
   default = "t2.micro"
#  default = "m1.medium"
}



variable "ami_id" {
#  default = "ami-0947d2ba12ee1ff75"    # Amazon linux AMI 2
   default = "ami-0dba2cb6798deb6d8"    # Ubuntu 20.04 LTS
#  default = "ami-0817d428a6fb68645"    # Ubuntu 18,04 LTS
#  default = "ami-0dc3ca5b357a16549"    # openSUSE 15.2
#  default = "ami-0a782e324655d1cc0"    # SLES 15.2
#  default = "ami-0a1cfbada2409e7dc"    # K3OS-v0.11.0 KW
}

variable "inst_type_default" {
   default = "t2.micro"
#  default = "m1.medium"
}
//
// locals.tf
//
#locals {
#   env_name = "kwer-test"
#}	

#--------------#
#  network.tf  #
#--------------#

resource "aws_vpc" "cloud0" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = var.vpc_name
    Region = var.aws_region
#    Environment = var.env
    Stage = var.stage
  }
}
#---------------#
#  gateways.tf  #
#---------------#

#--------------------------------------
resource "aws_internet_gateway" "igw1" {
  depends_on = [aws_vpc.cloud0]
  vpc_id = aws_vpc.cloud0.id
  
  tags = {
    Name = "igw1"
    Region = var.aws_region
    Environment = "prod"
  }
}

resource "null_resource" "igw1_dependency" {
  depends_on = [aws_internet_gateway.igw1]
}

#----------------------------------
resource "aws_nat_gateway" "ngw1" {
  depends_on = [aws_vpc.cloud0]
#  depends_on = [aws_eip.eip1]
  allocation_id = aws_eip.eip1.id
  subnet_id = aws_subnet.public1.id

  tags = {
    Name = "ngw1"
    Subnet = "public1"
    Stage = "archdev"
    Environment = "prod"
  }
}

resource "null_resource" "ngw1_dependency" {
  depends_on = [aws_nat_gateway.ngw1]
}

#--------------#
#  subnets.tf  #
#--------------#

resource "aws_subnet" "public1" {

  depends_on = [aws_vpc.cloud0]
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.cloud0.id
  availability_zone = "${var.aws_region}a"

  tags = { 
    Name        = "${var.vpc_name}-public1"
    Stage       = var.stage
    Environment = "prod"
  }
}

resource "aws_route_table" "igw1" {

#  depends_on = [null_resource.dependency_igw1]
  depends_on = [aws_internet_gateway.igw1]
  vpc_id = aws_vpc.cloud0.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = { 
    Name         = "${var.vpc_name}-igw1"
    Stage        = var.stage
    Subnet       = "public1"
    Environments = "prod"
  }
}

resource "aws_route_table_association" "public1-igw1" {

  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.igw1.id
}

#  *******************************
resource "aws_subnet" "private2" {

  depends_on = [aws_vpc.cloud0]
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.cloud0.id
  availability_zone = "us-east-1a"

  tags = { 
    Name        = "${var.vpc_name}-private2"
    Stage       = var.stage
    Subnet      = "private2"
    Environment = "prod"
  }
}
#
resource "aws_route_table" "ngw1_2" {

#  depends_on = [null_resouce.dependency_ngw1]
  depends_on = [aws_nat_gateway.ngw1]
  vpc_id = aws_vpc.cloud0.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw1.id
  }

  tags = {
    Name         = "${var.vpc_name}-ngw1_2"
    Stage        = var.stage
    Environments = "prod"
  }
}
#
resource "aws_route_table_association" "private2-ngw1_2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.ngw1_2.id
}

#------------------------------
resource "aws_subnet" "data3" {
  depends_on = [aws_vpc.cloud0]
  cidr_block        = "10.0.3.0/24"
  vpc_id            = aws_vpc.cloud0.id
  availability_zone = "us-east-1a"

  tags = {
    Name        = "${var.vpc_name}-data3"
    Stage       = var.stage
    Environment = "prod"
  }
}
#
resource "aws_route_table" "ngw1_3" {

#  depends_on = [null_resource.dependency_ngw1]
  depends_on = [aws_nat_gateway.ngw1]
  vpc_id = aws_vpc.cloud0.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw1.id
  }

  tags = {
    Name         = "${var.vpc_name}-ngw1_3"
    Stage        = var.stage
    Environments = "prod"
  }
}
#
resource "aws_route_table_association" "data3-ngw1_3" {
  subnet_id      = aws_subnet.data3.id
  route_table_id = aws_route_table.ngw1_3.id
}
// ******************
// security_groups.tf
// ******************
resource "aws_security_group" "ssh_all" {
  name = "ssh-all"

  vpc_id = aws_vpc.cloud0.id
  
  // opens SSH from all IPs
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  
  // Terraform removes the default rule
  // allow any:any out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-all"
  }
}
#--------------#
#  servers.tf  #
#--------------#

# resource "aws_instance" "node1-0" {
resource "aws_spot_instance_request" "node1-0" {
#  count=1
  depends_on = [null_resource.ngw1_dependency]
  wait_for_fulfillment = true
  spot_type = "one-time"  
  ami = var.ami_id
  instance_type = var.inst_type_default
  spot_price = "0.01"
  key_name = var.ami_key_pair_name
  vpc_security_group_ids = [aws_security_group.ssh_all.id]
  root_block_device { volume_size = "8" }

  tags = {
#    Name = "${var.env}-inst-${count.index}"
    Name = "${var.env}-inst-1"
    AMI = var.ami_name
    Inst_purch-opt = "spot" 
  }
  subnet_id = aws_subnet.public1.id

  provisioner "local-exec" {
    command = "echo The IP address is ${self.private_ip}"
  }
}

locals { tags = {
    Name = "public1-srv-1"
    AMI = var.ami_name
    Stage = "archdev"
    Environment = "prod"
    Inst_purch_opt = "spot"
}   }

resource "aws_ec2_tag" "public1" {  
  resource_id = aws_spot_instance_request.public1.spot_instance_id
  for_each = local.tags
  key      = each.key
  value    = each.value
}
#-------------------------------------
resource "aws_instance" "master2-0" {
# resource "aws_spot_instance_request" "master2-0" {
#  count = 1
  depends_on = [null_resource.ngw1_dependency]
  wait_for_fulfillment = true
  spot_type = "one-time"
  ami = var.ami_id
  instance_type = var.instance_type
#  spot_price    = "0.01"
  key_name = var.ami_key_pair_name
  vpc_security_group_ids = [aws_security_group.ssh_all.id]
  root_block_device { volume_size = "8" }

  tags = {
    Name = "private2-srv-spot"
    AMI  = var.ami_name  
    Stage = "archdev"
    Environment = "prod"
    Inst_purch_opt = "spot"
  }

  provisioner "local-exec" {
    command = "echo The IP address is ${self.private_ip}"
  }
  subnet_id = aws_subnet.private2.id
}

locals { tags2 = {
    Name = "private2-srv-1"
    AMI = var.ami_name
    Stage = "archdev"
    Environment = "prod"
    Inst_purch_opt = "spot"
}   }

resource "aws_ec2_tag" "private2" {
  resource_id = aws_spot_instance_request.private2.spot_instance_id  
  for_each = local.tags2
  key      = each.key
  value    = each.value
}

######################################
# resource "aws_instance" "data3" {
resource "aws_spot_instance_request" "data3" {
#  count = 1
  depends_on = [null_resource.ngw1_dependency]
  wait_for_fulfillment = true
  spot_type = "one-time"
  ami = var.ami_id
  instance_type = var.instance_type
  spot_price    = "0.01"
  key_name = var.ami_key_pair_name
  vpc_security_group_ids = [aws_security_group.ssh_all.id]
  root_block_device { volume_size = "8" }

  tags = {
    Name = "var.env-inst-3-spot"
    AMI  = var.ami_name
    Instance_type = "on demand"
  }

  provisioner "local-exec" {
    command = "echo The IP address is ${self.private_ip}"
  }
  subnet_id = aws_subnet.data3.id
}

locals { tags3 = {
    Name = "data3-srv-1"
    AMI = var.ami_name
    Stage = "archdev"
    Environment = "prod"
    Inst_purch_opt = "spot"
}   }

resource "aws_ec2_tag" "data3" {
  resource_id = aws_spot_instance_request.data3.spot_instance_id
  for_each = local.tags3
  key      = each.key
  value    = each.value
}
#----------#
#  eip.tf  #
#----------#

resource "aws_eip" "eip1" {
#  instance = aws_instance.hugo-ec2-instance.id
  vpc      = true
  
  tags = { 
    Name = "public-ip1"
    Region = var.aws_region
    Note = "cloud0"
#    Stage = archdev
#    Environment = var.env
  }
}
