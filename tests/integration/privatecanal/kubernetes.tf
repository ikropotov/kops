resource "aws_autoscaling_attachment" "bastion-privatecanal-example-com" {
  elb                    = "${aws_elb.bastion-privatecanal-example-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.bastion-privatecanal-example-com.id}"
}

resource "aws_autoscaling_attachment" "master-us-test-1a-masters-privatecanal-example-com" {
  elb                    = "${aws_elb.api-privatecanal-example-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-us-test-1a-masters-privatecanal-example-com.id}"
}

resource "aws_autoscaling_group" "bastion-privatecanal-example-com" {
  name                 = "bastion.privatecanal.example.com"
  launch_configuration = "${aws_launch_configuration.bastion-privatecanal-example-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.utility-us-test-1a-privatecanal-example-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "privatecanal.example.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "bastion.privatecanal.example.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/bastion"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "master-us-test-1a-masters-privatecanal-example-com" {
  name                 = "master-us-test-1a.masters.privatecanal.example.com"
  launch_configuration = "${aws_launch_configuration.master-us-test-1a-masters-privatecanal-example-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.us-test-1a-privatecanal-example-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "privatecanal.example.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-test-1a.masters.privatecanal.example.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-privatecanal-example-com" {
  name                 = "nodes.privatecanal.example.com"
  launch_configuration = "${aws_launch_configuration.nodes-privatecanal-example-com.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.us-test-1a-privatecanal-example-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "privatecanal.example.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.privatecanal.example.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "us-test-1a-etcd-events-privatecanal-example-com" {
  availability_zone = "us-test-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "privatecanal.example.com"
    Name                 = "us-test-1a.etcd-events.privatecanal.example.com"
    "k8s.io/etcd/events" = "us-test-1a/us-test-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "us-test-1a-etcd-main-privatecanal-example-com" {
  availability_zone = "us-test-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "privatecanal.example.com"
    Name                 = "us-test-1a.etcd-main.privatecanal.example.com"
    "k8s.io/etcd/main"   = "us-test-1a/us-test-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_eip" "us-test-1a-privatecanal-example-com" {
  vpc = true
}

resource "aws_elb" "api-privatecanal-example-com" {
  name = "api-privatecanal"

  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-privatecanal-example-com.id}"]
  subnets         = ["${aws_subnet.utility-us-test-1a-privatecanal-example-com.id}"]

  health_check = {
    target              = "TCP:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "api.privatecanal.example.com"
  }
}

resource "aws_elb" "bastion-privatecanal-example-com" {
  name = "bastion-privatecanal"

  listener = {
    instance_port     = 22
    instance_protocol = "TCP"
    lb_port           = 22
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.bastion-elb-privatecanal-example-com.id}"]
  subnets         = ["${aws_subnet.utility-us-test-1a-privatecanal-example-com.id}"]

  health_check = {
    target              = "TCP:22"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "bastion.privatecanal.example.com"
  }
}

resource "aws_iam_instance_profile" "bastions-privatecanal-example-com" {
  name  = "bastions.privatecanal.example.com"
  roles = ["${aws_iam_role.bastions-privatecanal-example-com.name}"]
}

resource "aws_iam_instance_profile" "masters-privatecanal-example-com" {
  name  = "masters.privatecanal.example.com"
  roles = ["${aws_iam_role.masters-privatecanal-example-com.name}"]
}

resource "aws_iam_instance_profile" "nodes-privatecanal-example-com" {
  name  = "nodes.privatecanal.example.com"
  roles = ["${aws_iam_role.nodes-privatecanal-example-com.name}"]
}

resource "aws_iam_role" "bastions-privatecanal-example-com" {
  name               = "bastions.privatecanal.example.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_bastions.privatecanal.example.com_policy")}"
}

resource "aws_iam_role" "masters-privatecanal-example-com" {
  name               = "masters.privatecanal.example.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.privatecanal.example.com_policy")}"
}

resource "aws_iam_role" "nodes-privatecanal-example-com" {
  name               = "nodes.privatecanal.example.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.privatecanal.example.com_policy")}"
}

resource "aws_iam_role_policy" "bastions-privatecanal-example-com" {
  name   = "bastions.privatecanal.example.com"
  role   = "${aws_iam_role.bastions-privatecanal-example-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_bastions.privatecanal.example.com_policy")}"
}

resource "aws_iam_role_policy" "masters-privatecanal-example-com" {
  name   = "masters.privatecanal.example.com"
  role   = "${aws_iam_role.masters-privatecanal-example-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.privatecanal.example.com_policy")}"
}

resource "aws_iam_role_policy" "nodes-privatecanal-example-com" {
  name   = "nodes.privatecanal.example.com"
  role   = "${aws_iam_role.nodes-privatecanal-example-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.privatecanal.example.com_policy")}"
}

resource "aws_internet_gateway" "privatecanal-example-com" {
  vpc_id = "${aws_vpc.privatecanal-example-com.id}"

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "privatecanal.example.com"
  }
}

resource "aws_key_pair" "kubernetes-privatecanal-example-com-c4a6ed9aa889b9e2c39cd663eb9c7157" {
  key_name   = "kubernetes.privatecanal.example.com-c4:a6:ed:9a:a8:89:b9:e2:c3:9c:d6:63:eb:9c:71:57"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.privatecanal.example.com-c4a6ed9aa889b9e2c39cd663eb9c7157_public_key")}"
}

resource "aws_launch_configuration" "bastion-privatecanal-example-com" {
  name_prefix                 = "bastion.privatecanal.example.com-"
  image_id                    = "ami-12345678"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.kubernetes-privatecanal-example-com-c4a6ed9aa889b9e2c39cd663eb9c7157.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.bastions-privatecanal-example-com.id}"
  security_groups             = ["${aws_security_group.bastion-privatecanal-example-com.id}"]
  associate_public_ip_address = true

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "master-us-test-1a-masters-privatecanal-example-com" {
  name_prefix                 = "master-us-test-1a.masters.privatecanal.example.com-"
  image_id                    = "ami-12345678"
  instance_type               = "m3.medium"
  key_name                    = "${aws_key_pair.kubernetes-privatecanal-example-com-c4a6ed9aa889b9e2c39cd663eb9c7157.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-privatecanal-example-com.id}"
  security_groups             = ["${aws_security_group.masters-privatecanal-example-com.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-test-1a.masters.privatecanal.example.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  ephemeral_block_device = {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-privatecanal-example-com" {
  name_prefix                 = "nodes.privatecanal.example.com-"
  image_id                    = "ami-12345678"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.kubernetes-privatecanal-example-com-c4a6ed9aa889b9e2c39cd663eb9c7157.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-privatecanal-example-com.id}"
  security_groups             = ["${aws_security_group.nodes-privatecanal-example-com.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.privatecanal.example.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "us-test-1a-privatecanal-example-com" {
  allocation_id = "${aws_eip.us-test-1a-privatecanal-example-com.id}"
  subnet_id     = "${aws_subnet.utility-us-test-1a-privatecanal-example-com.id}"
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.privatecanal-example-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.privatecanal-example-com.id}"
}

resource "aws_route" "private-us-test-1a-0-0-0-0--0" {
  route_table_id         = "${aws_route_table.private-us-test-1a-privatecanal-example-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.us-test-1a-privatecanal-example-com.id}"
}

resource "aws_route53_record" "api-privatecanal-example-com" {
  name = "api.privatecanal.example.com"
  type = "A"

  alias = {
    name                   = "${aws_elb.api-privatecanal-example-com.dns_name}"
    zone_id                = "${aws_elb.api-privatecanal-example-com.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/Z1AFAKE1ZON3YO"
}

resource "aws_route_table" "private-us-test-1a-privatecanal-example-com" {
  vpc_id = "${aws_vpc.privatecanal-example-com.id}"

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "private-us-test-1a.privatecanal.example.com"
  }
}

resource "aws_route_table" "privatecanal-example-com" {
  vpc_id = "${aws_vpc.privatecanal-example-com.id}"

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "privatecanal.example.com"
  }
}

resource "aws_route_table_association" "private-us-test-1a-privatecanal-example-com" {
  subnet_id      = "${aws_subnet.us-test-1a-privatecanal-example-com.id}"
  route_table_id = "${aws_route_table.private-us-test-1a-privatecanal-example-com.id}"
}

resource "aws_route_table_association" "utility-us-test-1a-privatecanal-example-com" {
  subnet_id      = "${aws_subnet.utility-us-test-1a-privatecanal-example-com.id}"
  route_table_id = "${aws_route_table.privatecanal-example-com.id}"
}

resource "aws_security_group" "api-elb-privatecanal-example-com" {
  name        = "api-elb.privatecanal.example.com"
  vpc_id      = "${aws_vpc.privatecanal-example-com.id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "api-elb.privatecanal.example.com"
  }
}

resource "aws_security_group" "bastion-elb-privatecanal-example-com" {
  name        = "bastion-elb.privatecanal.example.com"
  vpc_id      = "${aws_vpc.privatecanal-example-com.id}"
  description = "Security group for bastion ELB"

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "bastion-elb.privatecanal.example.com"
  }
}

resource "aws_security_group" "bastion-privatecanal-example-com" {
  name        = "bastion.privatecanal.example.com"
  vpc_id      = "${aws_vpc.privatecanal-example-com.id}"
  description = "Security group for bastion"

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "bastion.privatecanal.example.com"
  }
}

resource "aws_security_group" "masters-privatecanal-example-com" {
  name        = "masters.privatecanal.example.com"
  vpc_id      = "${aws_vpc.privatecanal-example-com.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "masters.privatecanal.example.com"
  }
}

resource "aws_security_group" "nodes-privatecanal-example-com" {
  name        = "nodes.privatecanal.example.com"
  vpc_id      = "${aws_vpc.privatecanal-example-com.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "nodes.privatecanal.example.com"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-privatecanal-example-com.id}"
  source_security_group_id = "${aws_security_group.masters-privatecanal-example-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-privatecanal-example-com.id}"
  source_security_group_id = "${aws_security_group.masters-privatecanal-example-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-privatecanal-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-privatecanal-example-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-privatecanal-example-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.bastion-privatecanal-example-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.bastion-elb-privatecanal-example-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-to-master-ssh" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-privatecanal-example-com.id}"
  source_security_group_id = "${aws_security_group.bastion-privatecanal-example-com.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "bastion-to-node-ssh" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-privatecanal-example-com.id}"
  source_security_group_id = "${aws_security_group.bastion-privatecanal-example-com.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-privatecanal-example-com.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-privatecanal-example-com.id}"
  source_security_group_id = "${aws_security_group.api-elb-privatecanal-example-com.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-privatecanal-example-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-privatecanal-example-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-privatecanal-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-privatecanal-example-com.id}"
  from_port                = 1
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-privatecanal-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-privatecanal-example-com.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-privatecanal-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-privatecanal-example-com.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-elb-to-bastion" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.bastion-privatecanal-example-com.id}"
  source_security_group_id = "${aws_security_group.bastion-elb-privatecanal-example-com.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "ssh-external-to-bastion-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.bastion-elb-privatecanal-example-com.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "us-test-1a-privatecanal-example-com" {
  vpc_id            = "${aws_vpc.privatecanal-example-com.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "us-test-1a"

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "us-test-1a.privatecanal.example.com"
  }
}

resource "aws_subnet" "utility-us-test-1a-privatecanal-example-com" {
  vpc_id            = "${aws_vpc.privatecanal-example-com.id}"
  cidr_block        = "172.20.4.0/22"
  availability_zone = "us-test-1a"

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "utility-us-test-1a.privatecanal.example.com"
  }
}

resource "aws_vpc" "privatecanal-example-com" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "privatecanal.example.com"
  }
}

resource "aws_vpc_dhcp_options" "privatecanal-example-com" {
  domain_name         = "us-test-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster = "privatecanal.example.com"
    Name              = "privatecanal.example.com"
  }
}

resource "aws_vpc_dhcp_options_association" "privatecanal-example-com" {
  vpc_id          = "${aws_vpc.privatecanal-example-com.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.privatecanal-example-com.id}"
}
