variable "class_a_address" {
  # NOTE ref: https://docs.aws.amazon.com/ja_jp/AmazonVPC/latest/UserGuide/VPC_Subnets.html
  # VPC を作成する場合は、 RFC 1918 に指定されているように、プライベート IPv4 アドレス範囲から CIDR ブロック (/16 以下) を指定することをお勧めします。
  # 10.0.0.0 - 10.255.255.255 (10/8 プレフィックス)
  # 172.16.0.0 - 172.31.255.255 (172.16/12 プレフィックス)
  # 192.168.0.0 - 192.168.255.255 (192.168/16 プレフィックス)
  default = "10"
}

data "aws_availability_zones" "available" {}

# refs: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.32.0
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${terraform.workspace}-vpc"
  cidr = "${var.class_a_address}.0.0.0/16"

  # 2018/07/20現在 ap regionはEKS対応していないのでEKS使う場合はus-westにする
  azs              = [ "${data.aws_availability_zones.available.names[0]}",
                       "${data.aws_availability_zones.available.names[1]}",
                       "${data.aws_availability_zones.available.names[2]}" ]

  public_subnets   = ["${var.class_a_address}.0.0.0/24", "${var.class_a_address}.0.1.0/24", "${var.class_a_address}.0.2.0/24"]
  private_subnets  = ["${var.class_a_address}.0.100.0/18"]
  database_subnets = ["${var.class_a_address}.0.200.0/22", "${var.class_a_address}.0.210.0/22", "${var.class_a_address}.0.220.0/22"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  # ref: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  # TODO: variable化してvpc.tfのnameと合わせてEKS使うときだけ書きたい
  tags = {
    Terraform   = "true"
    Environment = "${terraform.workspace}",
    "kubernetes.io/cluster/${terraform.workspace}-eks-cluster" = "shared",
  }
}

resource "aws_network_acl" "private_acl" {
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.vpc.private_subnets}"]

  # inbound
  # TODO: 全開放でいいか確認する
  # application port全開放
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  # TODO: 意図を記述する
  # (多分)VPC internal accessに対してすべてのportを許可する
  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "${var.class_a_address}.0.0.0/16"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags {
    Name = "${terraform.workspace}-private-acl"
  }
}

resource "aws_network_acl" "public_acl" {
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.vpc.public_subnets}"]

  # inbound
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 30000
    to_port    = 65535
  }

  # TODO: 意図を記述する
  # (多分)VPC internal accessに対してすべてのportを許可する
  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "${var.class_a_address}.0.0.0/16"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags {
    Name = "${terraform.workspace}-public-acl"
  }
}

/* TODO:
気持ち的には private_subnet からのみallow
RDSへのアクセス制御がnetwork aclを用いて行うのが適切なのかよくわかってないのでコメントアウト中

resource "aws_network_acl" "db_acl" {
  # inbound
  ingress {
    rule_no = 100
    action = "allow"
    protocol = "tcp"
    cidr_block = "0.0.0.0/16"
    from_port = 32768
    to_port = 65535
  }

  tags {
    Name = "${terraform.workspace}-db-acl"
  }
}
*/

