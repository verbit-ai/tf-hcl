//
// Module: cluster
//

resource "aws_instance" "cluster_ephemeral" {
  count = "${var.ephemeral_storage ? var.instance_count : 0}"
  ami = "${element(split(",", var.ami), count.index)}"
  placement_group = "${element(split(",", var.placement_group), count.index)}"
  tenancy = "${element(split(",", var.tenancy), count.index)}"
  ebs_optimized = "${element(split(",", var.ebs_optimized), count.index)}"
  disable_api_termination = "${element(split(",", var.disable_api_termination), count.index)}"
  instance_initiated_shutdown_behavior = "${element(split(",", var.instance_initiated_shutdown_behavior), count.index)}"
  instance_type = "${element(split(",", var.instance_type), count.index)}"
  key_name = "${element(split(",", var.key_name), count.index)}"
  monitoring = "${element(split(",", var.monitoring), count.index)}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  subnet_id = "${element(split(",", var.subnet_id), count.index)}"
  associate_public_ip_address = "${element(split(",", var.associate_public_ip_address), count.index)}"
  private_ip = "${element(split(",", var.private_ip), count.index)}"
  source_dest_check = "${element(split(",", var.source_dest_check), count.index)}"
  user_data = "${element(split(",", var.user_data), count.index)}"
  // user_data_base64 = "${element(split(",", var.user_data_base64), count.index)}"
  iam_instance_profile = "${element(split(",", var.iam_instance_profile), count.index)}"
  tags = "${var.tags}"
  volume_tags = "${var.tags}"
  // Cannot conditionally declare block device mappings. Using Volume resource instead.

  root_block_device = {
    volume_size = "${element(split(",", var.root_volume_size), count.index)}"
    volume_type = "${element(split(",", var.root_volume_type), count.index)}"
    iops = "${element(split(",", var.root_volume_piops), count.index)}"
  }

  ephemeral_block_device {
    device_name = "xvdcw"
    virtual_name = "ephemeral0"
  }

  ephemeral_block_device {
    device_name = "xvdcy"
    virtual_name = "ephemeral1"
  }

  ephemeral_block_device {
    device_name = "xvdcx"
    virtual_name = "ephemeral2"
  }

  ephemeral_block_device {
    device_name = "xvdcz"
    virtual_name = "ephemeral3"
  }
}

resource "aws_instance" "cluster_ebs" {
  count = "${!var.ephemeral_storage ? var.instance_count : 0}"
  ami = "${element(split(",", var.ami), count.index)}"
  placement_group = "${element(split(",", var.placement_group), count.index)}"
  tenancy = "${element(split(",", var.tenancy), count.index)}"
  ebs_optimized = "${element(split(",", var.ebs_optimized), count.index)}"
  disable_api_termination = "${element(split(",", var.disable_api_termination), count.index)}"
  instance_initiated_shutdown_behavior = "${element(split(",", var.instance_initiated_shutdown_behavior), count.index)}"
  instance_type = "${element(split(",", var.instance_type), count.index)}"
  key_name = "${element(split(",", var.key_name), count.index)}"
  monitoring = "${element(split(",", var.monitoring), count.index)}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  subnet_id = "${element(split(",", var.subnet_id), count.index)}"
  associate_public_ip_address = "${element(split(",", var.associate_public_ip_address), count.index)}"
  private_ip = "${element(split(",", var.private_ip), count.index)}"
  source_dest_check = "${element(split(",", var.source_dest_check), count.index)}"
  user_data = "${element(split(",", var.user_data), count.index)}"
  //  user_data_base64 = "${element(split(",", var.user_data_base64), count.index)}"
  iam_instance_profile = "${element(split(",", var.iam_instance_profile), count.index)}"
  tags = "${var.tags}"
  volume_tags = "${var.tags}"

  // Cannot conditionally declare block device mappings. Using Volume resource instead.

  root_block_device = {
    volume_size = "${element(split(",", var.root_volume_size), count.index)}"
    volume_type = "${element(split(",", var.root_volume_type), count.index)}"
    iops = "${element(split(",", var.root_volume_piops), count.index)}"
    delete_on_termination = "${element(split(",", var.root_delete_on_termination), count.index)}"
  }
}

resource "aws_ebs_volume" "cluster_ebs_volume" {
  count = "${!var.ephemeral_storage ? var.extra_volumes_count * var.instance_count : 0}"
  availability_zone = "${aws_instance.cluster_ebs.*.availability_zone[count.index / var.extra_volumes_count]}"
  size = "${element(split(",", var.extra_volume_size), count.index)}"
  type = "${element(split(",", var.extra_volume_type), count.index)}"
  encrypted = "${element(split(",", var.extra_volume_encrypted), count.index)}"
  iops = "${element(split(",", var.extra_volume_piops), count.index)}"
  kms_key_id = "${element(split(",", var.extra_volume_kms_key_id), count.index)}"
  tags = "${merge(var.tags, var.volume_tags[count.index])}"
}

resource "aws_volume_attachment" "cluster_ebs_volume_attachment" {
  count = "${!var.ephemeral_storage ? var.extra_volumes_count * var.instance_count : 0}"
  device_name = "${element(split(",", var.extra_volume_device_name), count.index)}"
  volume_id = "${aws_ebs_volume.cluster_ebs_volume.*.id[count.index]}"
  instance_id = "${aws_instance.cluster_ebs.*.id[count.index / var.extra_volumes_count]}"
}

resource "aws_eip" "cluster_ebs_eip" {
  count = "${!var.ephemeral_storage && var.eip ? var.instance_count : 0}"
  instance = "${element(aws_instance.cluster_ebs.*.id, count.index)}"
  vpc = true
}

resource "aws_ebs_volume" "cluster_ephemeral_volume" {
  count = "${var.ephemeral_storage ? var.extra_volumes_count * var.instance_count : 0}"
  availability_zone = "${aws_instance.cluster_ephemeral.*.availability_zone[count.index / var.extra_volumes_count]}"
  size = "${element(split(",", var.extra_volume_size), count.index)}"
  type = "${element(split(",", var.extra_volume_type), count.index)}"
  encrypted = "${element(split(",", var.extra_volume_encrypted), count.index)}"
  iops = "${element(split(",", var.extra_volume_piops), count.index)}"
  kms_key_id = "${element(split(",", var.extra_volume_kms_key_id), count.index)}"
  tags = "${merge(var.tags, var.volume_tags[count.index])}"
}

resource "aws_volume_attachment" "cluster_ephemeral_volume_attachment" {
  count = "${var.ephemeral_storage ? var.extra_volumes_count * var.instance_count : 0}"
  device_name = "${element(split(",", var.extra_volume_device_name), count.index)}"
  volume_id = "${aws_ebs_volume.cluster_ephemeral_volume.*.id[count.index]}"
  instance_id = "${aws_instance.cluster_ephemeral.*.id[count.index / var.extra_volumes_count]}"
}

resource "aws_eip" "cluster_ephemeral_eip" {
  count = "${var.ephemeral_storage && var.eip ? var.instance_count : 0}"
  instance = "${element(aws_instance.cluster_ephemeral.*.id, count.index)}"
  vpc = true
}


