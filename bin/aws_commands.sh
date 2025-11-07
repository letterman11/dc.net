#aws ec2 start-instances --instance-ids $(aws ec2 describe-instances --filters Name=tag:<key>,Values=<value> --query "Reservations[*].Instances[*].InstanceId" --output text)

#aws ec2 reboot-instances --instance-ids $(aws ec2 describe-instances --filters Name=tag:<key>,Values=<value> --query "Reservations[*].Instances[*].InstanceId" --output text)

#aws ec2 stop-instances --instance-ids $(aws ec2 describe-instances --filters Name=tag:<key>,Values=<value> --query "Reservations[*].Instances[*].InstanceId" --output text)


#--- List Running instances
#aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,PublicIpAddress,PrivateIpAddress,Tags[?Key==`Name`].Value | [0]]' --output table



aws ec2 start-instances --instance-ids $(aws ec2 describe-instances --filters Name=tag:"Name",Values="some-server" --query "Reservations[*].Instances[*].InstanceId" --output text)
