variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "zone" {}

provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "alicloud_ram_role" "role" {
  name = "testrole"
  services = [
    "ecs.aliyuncs.com"]
  ram_users = ["acs:ram::5450581093456520:root"]
  description = "this is a role test."
  force = true
}

resource "alicloud_ram_role_attachment" "role_attachment" {
  role_name = "${alicloud_ram_role.role.name}"
  instance_ids = ["${alicloud_instance.web.id}"]
}

resource "alicloud_security_group" "sg" {
  name   = "terraform-sg"
  vpc_id = "${alicloud_vpc.vpc.id}"
}

resource "alicloud_security_group_rule" "allow_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_vpc" "vpc" {
  name = "terraform-vpc"
  cidr_block = "10.1.0.0/21"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${var.zone}"
}

resource "alicloud_eip" "eip" {
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "eip_asso" {
  allocation_id = "${alicloud_eip.eip.id}"
  instance_id   = "${alicloud_instance.web.id}"
}

resource "alicloud_instance" "web" {
  instance_name = "terraform-ecs"
  availability_zone = "${var.zone}"
  image_id = "centos_7_3_64_40G_base_20170322.vhd"
  instance_type = "ecs.n4.small"
  system_disk_category = "cloud_efficiency"
  security_groups = ["${alicloud_security_group.sg.id}"]
  vswitch_id = "${alicloud_vswitch.vsw.id}"
}